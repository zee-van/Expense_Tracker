import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/model/group_expense_name.dart';

final addGroupExpenseNameProvider =
    AsyncNotifierProvider<GroupExpenseNameProvider, void>(
      GroupExpenseNameProvider.new,
    );

class GroupExpenseNameProvider extends AsyncNotifier {
  @override
  FutureOr build() {}

  Future<void> addGroupExpenseName(GroupExpenseNameData expenseName) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .add(expenseName.toMap());
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
