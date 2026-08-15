class MChatQuestion {
  final String id;
  final int questionNumber;
  final String textTagalog;
  final String textEnglish;
  final String example;
  final bool atRiskAnswer;

  MChatQuestion({
    required this.id,
    required this.questionNumber,
    required this.textTagalog,
    required this.textEnglish,
    required this.example,
    required this.atRiskAnswer,
  });

  factory MChatQuestion.fromJson(Map<String, dynamic> json) {
    return MChatQuestion(
      id: json['id'] as String,
      questionNumber: json['questionNumber'] as int,
      textTagalog: json['textTagalog'] as String,
      textEnglish: json['textEnglish'] as String,
      example: json['example'] as String,
      atRiskAnswer: json['atRiskAnswer'] as bool,
    );
  }
}