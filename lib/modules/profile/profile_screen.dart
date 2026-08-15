import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ChildProfile> _children = [];
  String? _activeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _children = HiveService.getAllChildProfiles();
      _activeId = HiveService.getActiveChildId();
    });
  }

  Future<void> _setActive(String id) async {
    await HiveService.setActiveChildId(id);
    _load();
  }

  Future<void> _confirmDelete(ChildProfile child) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Burahin ang profile?'),
        content: Text(
          'Buburahin si ${child.name}. Mananatili ang mga naitalang screening result, '
          'ngunit hindi na sila maiuugnay sa isang bata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kanselahin'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Burahin',
              style: TextStyle(color: Color(0xFFD9383A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await HiveService.deleteChildProfile(child.id);
      _load();
    }
  }

  Future<void> _openEditor({ChildProfile? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _ChildEditorDialog(existing: existing),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile ng Bata'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.logoGreen,
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Magdagdag',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _children.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Wala pang naitalang bata.',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ang pangalan at kaarawan ay lalabas sa PDF report, at gagamitin sa pagkwenta ng edad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
            )
          : RadioGroup<String>(
              groupValue: _activeId,
              onChanged: (value) {
                if (value != null) _setActive(value);
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: _children.length,
                itemBuilder: (context, index) {
                  final child = _children[index];
                  final isActive = child.id == _activeId;
                  final months = child.ageInMonthsOn(DateTime.now());
                  final birth =
                      '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isActive ? const Color(0xFFF1FAF4) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isActive ? AppColors.logoGreen : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: Radio<String>(
                        value: child.id,
                        activeColor: AppColors.logoGreen,
                      ),
                      title: Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Kaarawan: $birth  •  $months buwan ngayon'),
                      onTap: () => _setActive(child.id),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColors.logoGreen),
                            tooltip: 'Baguhin',
                            onPressed: () => _openEditor(existing: child),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD9383A)),
                            tooltip: 'Burahin',
                            onPressed: () => _confirmDelete(child),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _ChildEditorDialog extends StatefulWidget {
  final ChildProfile? existing;

  const _ChildEditorDialog({this.existing});

  @override
  State<_ChildEditorDialog> createState() => _ChildEditorDialogState();
}

class _ChildEditorDialogState extends State<_ChildEditorDialog> {
  late final TextEditingController _nameController;
  DateTime? _birthDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _birthDate = widget.existing?.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 2, now.month, now.day),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.logoGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Kailangan ang pangalan.');
      return;
    }
    if (_birthDate == null) {
      setState(() => _error = 'Kailangan ang kaarawan.');
      return;
    }

    final profile = ChildProfile(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      birthDate: _birthDate!,
    );
    await HiveService.saveChildProfile(profile);

    // Kapag ito ang unang bata, gawin nang aktibo agad para may magamit ang screening.
    if (HiveService.getActiveChildId() == null) {
      await HiveService.setActiveChildId(profile.id);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final birthText = _birthDate == null
        ? 'Pumili ng kaarawan'
        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.existing == null ? 'Bagong Bata' : 'Baguhin ang Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Pangalan ng bata',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.logoGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _pickDate,
            icon: const Icon(Icons.cake_rounded, color: AppColors.logoGreen),
            label: Text(
              birthText,
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFD9383A), fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Kanselahin'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.logoGreen),
          onPressed: _save,
          child: const Text(
            'I-save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
