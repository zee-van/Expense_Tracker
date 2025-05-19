class GroupExpenseNameData {
  final String admin;
  final DateTime createdAt;
  final String groupName;
  final List<String> members;

  const GroupExpenseNameData({
    required this.admin,
    required this.groupName,
    required this.createdAt,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'admin': admin,
      'createdAt': createdAt,
      'groupName': groupName,
      'members': members,
    };
  }
}
