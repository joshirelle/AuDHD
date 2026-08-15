import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'mchat_screening_screen.dart';

class MChatAgeCheckScreen extends StatefulWidget {
  const MChatAgeCheckScreen({super.key});

  @override
  State<MChatAgeCheckScreen> createState() => _MChatAgeCheckScreenState();
}

class _MChatAgeCheckScreenState extends State<MChatAgeCheckScreen> {
  DateTime? _selectedDate;
  int? _ageInMonths;

  void _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    setState(() {
      _selectedDate = birthDate;
      _ageInMonths = months;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // Default 2 yrs old
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.logoGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _calculateAge(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isValidAge = _ageInMonths != null && _ageInMonths! >= 16 && _ageInMonths! <= 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tsek ng Edad'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ilang taon/buwan na si Kiko?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Ang M-CHAT-R/F ay idinisenyo para sa mga batang 16 hanggang 30 buwang gulang (1.3 hanggang 2.5 taon).',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // Date Picker Button
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.logoGreen, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cake_rounded, color: AppColors.logoGreen, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Petsa ng Kapanganakan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null
                                  ? 'Pumili ng Petsa'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.logoGreen),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Age Indicator Result
            if (_ageInMonths != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isValidAge ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isValidAge ? Colors.green : Colors.orange,
                  ),
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
                            'Edad: $_ageInMonths na Buwan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isValidAge ? Colors.green.shade900 : Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isValidAge
                                ? 'Angkop ang edad ni Kiko para sa M-CHAT-R screening!'
                                : _ageInMonths! < 16
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
            ],

            const Spacer(),

            // Proceed Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _selectedDate == null
                  ? null
                  : () {
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