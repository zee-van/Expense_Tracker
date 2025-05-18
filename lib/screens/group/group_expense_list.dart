import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/group/add_group_expenses.dart';
import 'package:expense_tracker/screens/group/add_member_to_group.dart';
import 'package:expense_tracker/screens/group/group_expense_name.dart';
import 'package:expense_tracker/screens/group/see_group_member.dart';
import 'package:expense_tracker/screens/group/settings.dart';
import 'package:expense_tracker/widgets/common_widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupExpenseListScreen extends StatefulWidget {
  const GroupExpenseListScreen({super.key});

  @override
  State<GroupExpenseListScreen> createState() => _GroupExpenseListScreenState();
}

class _GroupExpenseListScreenState extends State<GroupExpenseListScreen> {
  final loggedUser = FirebaseAuth.instance.currentUser;

  void _showGroupsFeatures(String groupName, String adminId, String id) async {
    final adminDoc =
        await FirebaseFirestore.instance.collection('users').doc(adminId).get();
    final admin = adminDoc.data()!['name'];
    if (mounted) {
      showModalBottomSheet(
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return SizedBox(
            // height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(groupName, style: TextStyle(fontSize: 22)),
                      Text('Created By: $admin'),
                      SizedBox(height: 30),
                      ElevatedButtonWidget(
                        onTap: () {
                          Navigator.of(context).pop();
                          _showSeeMembersModal(id);
                        },
                        label: Row(
                          children: [
                            SizedBox(width: 20),
                            Icon(
                              Icons.group,
                              size: 25,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'See Members',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      ElevatedButtonWidget(
                        onTap: () {
                          Navigator.of(context).pop();
                          _addMembersToGroup(id);
                        },
                        label: Row(
                          children: [
                            SizedBox(width: 20),
                            Icon(
                              Icons.person,
                              size: 25,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Add Members',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      ElevatedButtonWidget(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => SettingsPage(
                                    adminId: adminId,
                                    groupId: id,
                                  ),
                            ),
                          );
                        },
                        label: Row(
                          children: [
                            SizedBox(width: 20),
                            Icon(
                              Icons.settings,
                              size: 25,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'Settings',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showSeeMembersModal(String id) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SeeGroupMemberScreen(groupId: id);
      },
    );
  }

  void _addMembersToGroup(String groupId) async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: AddMemberToGroup(groupId: groupId),
            );
          },
        );
      }
    } catch (e) {
      setState(() {});
    }
  }

  void _createNewGroupExpense() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: GroupExpenseName(),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: GroupExpenseName(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('groups')
              .where('members', arrayContains: loggedUser!.uid)
              .snapshots(),
      builder: (content, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshots.hasError) {
          return Center(
            child: Text('Some thing went wrong, check your connection'),
          );
        }
        final groups = snapshots.data!.docs;
        if (groups.isEmpty) {
          return Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(233, 213, 112, 169),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Welcome to Group Expenses!',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'You can create and manage your group expenses easily by adding your members.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      _createNewGroupExpense();
                    },
                    child: Text('Create New Group Expense'),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ListView(
              children: [
                for (final group in groups)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (ctx) =>
                                    AddGroupExpensesScreen(groupDetails: group),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.only(top: 4),
                      leading: CircleAvatar(child: Text(group['groupName'][0])),
                      title: Text(group['groupName']),
                      subtitle:
                          group['admin'] == loggedUser!.uid
                              ? Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Your group',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              )
                              : Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Member',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                      trailing: TextButton(
                        onPressed: () {
                          _showGroupsFeatures(
                            group['groupName'],
                            group['admin'],
                            group.id,
                          );
                        },
                        child: Icon(Icons.more_vert),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
