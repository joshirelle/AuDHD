class ADHDQuestion {
  final String id;
  final int number;
  final String textTagalog;
  final String textEnglish;
  final String category; // 'Inattention' o 'Hyperactivity'

  ADHDQuestion({
    required this.id,
    required this.number,
    required this.textTagalog,
    required this.textEnglish,
    required this.category,
  });

  factory ADHDQuestion.fromJson(Map<String, dynamic> json) {
    return ADHDQuestion(
      id: json['id'] as String,
      number: json['number'] as int,
      textTagalog: json['textTagalog'] as String,
      textEnglish: json['textEnglish'] as String,
      category: json['category'] as String,
    );
  }
}