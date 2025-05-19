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
  bool _isRemoving = false;

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
                            Icon(Icons.group, size: 25),
                            SizedBox(width: 15),
                            Text('See Members'),
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
                            Icon(Icons.person, size: 25),
                            SizedBox(width: 15),
                            Text('Add Members'),
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
                            Icon(Icons.settings, size: 25),
                            SizedBox(width: 15),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      if (adminId == loggedUser!.uid) SizedBox(height: 5),
                      if (adminId == loggedUser!.uid)
                        ElevatedButtonWidget(
                          onTap: () {
                            Navigator.of(context).pop();
                            _deleteWholeExpenseGroup(id);
                          },
                          label: Row(
                            children: [
                              SizedBox(width: 20),
                              Icon(Icons.delete, size: 25),
                              SizedBox(width: 15),
                              Text('Delete The Group'),
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

  void _deleteWholeExpenseGroup(String id) async {
    final groupName =
        await FirebaseFirestore.instance.collection('groups').doc(id).get();
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text('Conform Delete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are tou sure want to remove this (${groupName.data()!['groupName']}) group Expense Permanantly.',
                ),
                Text('It will delete all related expenses as well.'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButtonWidget(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      label: Text('Cancel'),
                    ),
                    SizedBox(width: 15),
                    OutlinedButtonWidget(
                      onTap: () {
                        _confirmDeleteGroupExpense(id);
                        if (!_isRemoving) {
                          Navigator.of(context).pop();
                        }
                      },
                      label: Text('Conform'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _confirmDeleteGroupExpense(String id) async {
    try {
      setState(() {
        _isRemoving = true;
      });
      FirebaseFirestore.instance.collection('groups').doc(id).delete();
      setState(() {
        _isRemoving = false;
      });
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('groupExpenses')
              .where('groupId', isEqualTo: id)
              .get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      setState(() {
        _isRemoving = false;
        Navigator.of(context).pop();
      });
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 2,
                    spreadRadius: 1,
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
                  SizedBox(height: 30),
                  ElevatedButtonWidget(
                    onTap: () {
                      _createNewGroupExpense();
                    },
                    label: Text('Create New Group Expense'),
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
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    padding: const EdgeInsets.only(top: 6, bottom: 6, left: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          blurRadius: 2,
                          spreadRadius: 1,
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
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        child: Text(group['groupName'][0]),
                      ),
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
                        child: Icon(
                          Icons.more_vert,
                          size: 25,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
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
