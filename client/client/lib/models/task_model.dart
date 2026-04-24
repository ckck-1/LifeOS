class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime scheduledFor;
  final String status;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.scheduledFor,
    this.status = 'pending',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduledFor: DateTime.parse(json['scheduledFor']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        "type": "work",
        "title": title,
        "description": description,
        "scheduledFor": scheduledFor.toIso8601String(),
        "aiGenerated": false,
      };
}