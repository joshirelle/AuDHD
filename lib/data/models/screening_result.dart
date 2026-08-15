class ScreeningResult {
  static const String typeMChat = 'MCHAT';
  static const String typeADHD = 'ADHD';

  final String id;
  final DateTime date;
  final int score;
  final String riskLevel;
  final String type;
  final Map<String, dynamic> answers; // bool para sa M-CHAT, int 0-3 para sa ADHD

  ScreeningResult({
    required this.id,
    required this.date,
    required this.score,
    required this.riskLevel,
    required this.type,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'score': score,
      'riskLevel': riskLevel,
      'type': type,
      'answers': answers,
    };
  }

  factory ScreeningResult.fromMap(Map<dynamic, dynamic> map) {
    return ScreeningResult(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      score: map['score'] as int,
      riskLevel: map['riskLevel'] as String,
      // Walang 'type' ang mga record na na-save bago idagdag ang ADHD; M-CHAT ang lahat ng iyon.
      type: map['type'] as String? ?? typeMChat,
      answers: Map<String, dynamic>.from(map['answers'] as Map),
    );
  }
}