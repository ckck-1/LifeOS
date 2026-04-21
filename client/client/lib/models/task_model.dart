class LifeTask {
  final String? id;
  final String title;
  final String description;
  final String type;
  final int aiRank;
  final DateTime scheduledFor;
  final bool aiGenerated;
  bool completed;
  String? completedAt;

  LifeTask({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.aiRank,
    required this.scheduledFor,
    this.aiGenerated = false,
    this.completed = false,
    this.completedAt,
  });

  factory LifeTask.fromJson(Map<String, dynamic> json) {
    return LifeTask(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'work',
      aiRank: json['aiRank'] ?? 4,
      scheduledFor: DateTime.parse(json['scheduledFor'] ?? DateTime.now().toIso8601String()),
      aiGenerated: json['aiGenerated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "type": type,
        "scheduledFor": scheduledFor.toIso8601String(),
        "aiGenerated": aiGenerated,
      };
}