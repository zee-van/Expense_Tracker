import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeeGroupMemberScreen extends StatefulWidget {
  const SeeGroupMemberScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<SeeGroupMemberScreen> createState() => _SeeGroupMemberScreenState();
}

class _SeeGroupMemberScreenState extends State<SeeGroupMemberScreen> {
  List<Map<String, dynamic>> membersData = [];
  List<String> membersList = [];
  final loggedUser = FirebaseAuth.instance.currentUser;
  bool _isRemoving = false;
  @override
  void initState() {
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> _getMembersStream(List<String> memberIds) {
    return Stream<List<Map<String, dynamic>>>.multi((controller) {
      final List<Map<String, dynamic>> members = [];

      for (String memberId in memberIds) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .snapshots()
            .listen((userSnapshot) {
              if (userSnapshot.exists) {
                members.add(userSnapshot.data() as Map<String, dynamic>);
                controller.add(List.from(members)); // Emit a new list each time
              }
            });
      }
    });
  }

  void _showDeleteModal(String id, String name) async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Conform Delete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Are tou sure want to remove this user($name) from your group.',
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 15),
                    OutlinedButton(
                      onPressed: () {
                        _confirmDelete(id);
                        if (!_isRemoving) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Conform'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Conform Delete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Are tou sure want to remove this user($name) from your group.',
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 15),
                    OutlinedButton(
                      onPressed: () {
                        _confirmDelete(id);
                        if (!_isRemoving) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Conform'),
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

  void _confirmDelete(String id) async {
    try {
      setState(() {
        _isRemoving = true;
      });
      final docToUpdate = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId);
      await docToUpdate.update({
        'members': FieldValue.arrayRemove([id]),
      });
      setState(() {
        _isRemoving = false;
      });
    } catch (e) {
      setState(() {
        _isRemoving = false;
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16),
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshots.hasError) {
                  return Center(child: Text('Someting went wrong'));
                }
                List<String> memberIds = List<String>.from(
                  snapshots.data!['members'],
                );
                if (memberIds.isEmpty) {
                  return Center(child: Text('No expenses added'));
                }
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getMembersStream(memberIds),
                  builder: (context, membersSnapshot) {
                    if (membersSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!membersSnapshot.hasData ||
                        membersSnapshot.data!.isEmpty) {
                      return Center(child: Text('No members found'));
                    }

                    return ListView.builder(
                      itemCount: membersSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final member = membersSnapshot.data![index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            child: Text(member['name'][0]),
                          ),
                          title:
                              snapshots.data!['admin'] == memberIds[index]
                                  ? Text('${member['name']}(Admin)')
                                  : loggedUser!.uid == memberIds[index]
                                  ? Text('${member['name']}(you)')
                                  : Text('${member['name']}'),
                          subtitle: Text(member['email'] ?? 'No Email'),
                          trailing:
                              snapshots.data!['admin'] == loggedUser!.uid
                                  ? snapshots.data!['admin'] == memberIds[index]
                                      ? null
                                      : IconButton(
                                        onPressed: () {
                                          _showDeleteModal(
                                            memberIds[index],
                                            member['name'],
                                          );
                                        },
                                        icon: Icon(Icons.delete),
                                      )
                                  : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
