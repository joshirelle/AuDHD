import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/services/hive_service.dart';
import '../../profile/child_editor_dialog.dart';
import 'mchat_screening_screen.dart';

class MChatAgeCheckScreen extends StatefulWidget {
  const MChatAgeCheckScreen({super.key});

  @override
  State<MChatAgeCheckScreen> createState() => _MChatAgeCheckScreenState();
}

class _MChatAgeCheckScreenState extends State<MChatAgeCheckScreen> {
  ChildProfile? _child;

  @override
  void initState() {
    super.initState();
    _child = HiveService.getActiveChild();
  }

  Future<void> _editProfile(ChildProfile child) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ChildEditorDialog(existing: child),
    );
    if (saved == true) {
      setState(() => _child = HiveService.getActiveChild());
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _child;
    final int ageInMonths =
        child == null ? 0 : child.ageInMonthsOn(DateTime.now());
    final bool isValidAge =
        child != null && ageInMonths >= 16 && ageInMonths <= 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tsek ng Edad'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: child == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Walang piniling bata. Bumalik at pumili muna sa Profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Angkop ba ang edad ni ${child.name}?',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ang M-CHAT-R/F ay idinisenyo para sa mga batang 16 hanggang 30 buwang gulang (1.3 hanggang 2.5 taon).',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),

                  // Galing sa naitalang profile — hindi na muling itinatanong.
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.logoGreen, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_rounded, color: AppColors.logoGreen, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Petsa ng Kapanganakan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _editProfile(child),
                          child: const Text(
                            'Baguhin',
                            style: TextStyle(color: AppColors.logoGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Age Indicator Result
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isValidAge ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isValidAge ? Colors.green : Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isValidAge ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          color: isValidAge ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edad: $ageInMonths na Buwan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isValidAge ? Colors.green.shade900 : Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isValidAge
                                    ? 'Angkop ang edad ni ${child.name} para sa M-CHAT-R screening!'
                                    : ageInMonths < 16
                                        ? 'Masyado pang bata para sa M-CHAT. Inirerekomenda na sumubok ulit kapag 16 buwan na.'
                                        : 'Lagpas na sa 30 buwan. Maaari pa ring gamitin ang test, ngunit mas maganda ang direktang pangkonsulta sa Developmental Pediatrician.',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Proceed Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MChatScreeningScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Ipagpatuloy ang Screening',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}