enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      // Remove ID from the map since Firestore handles it separately
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toString(),
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId, // Use the Firestore document ID
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == map['priority'],
        orElse: () => TaskPriority.low,
      ),
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }
}
