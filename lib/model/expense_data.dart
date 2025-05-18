class PersonalExpenseData {
  final String category;
  final int amount;
  final DateTime date;
  final String description;
  final String title;
  final String userId;

  const PersonalExpenseData({
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.title,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
      'title': title,
      'userId': userId,
    };
  }
}

class GroupExpenseData {
  final String category;
  final int amount;
  final DateTime date;
  final String description;
  final String groupId;
  final String title;
  final String userId;

  const GroupExpenseData({
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.groupId,
    required this.title,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
      'groupId': groupId,
      'title': title,
      'userId': userId,
    };
  }
}
