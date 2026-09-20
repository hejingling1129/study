class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.date,
    this.dueTime = '',
    this.note = '',
    this.completed = false,
    this.category = 'study',
  });

  final String id;
  final String title;
  final String date;
  final String dueTime;
  final String note;
  final bool completed;
  final String category;

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: '${json['id']}',
      title: '${json['title'] ?? ''}',
      date: '${json['date'] ?? ''}',
      dueTime: '${json['due_time'] ?? ''}',
      note: '${json['note'] ?? ''}',
      completed: json['completed'] == true,
      category: '${json['category'] ?? 'study'}',
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'contest':
        return '竞赛';
      case 'document':
        return '文书';
      default:
        return '学习';
    }
  }
}
