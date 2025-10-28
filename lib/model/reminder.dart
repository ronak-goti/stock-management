class Reminder {
  final String title;
  final String description;
  final DateTime date;

  Reminder({required this.title, required this.description, required this.date});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    title: json['title'],
    description: json['description'],
    date: DateTime.parse(json['date']),
  );
}