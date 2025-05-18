import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addGroupExpenseProvider =
    AsyncNotifierProvider<AddGroupExpenseProvider, void>(
      AddGroupExpenseProvider.new,
    );

class AddGroupExpenseProvider extends AsyncNotifier {
  @override
  Future<void> build() async {}

  Future<void> addGroupExpense(GroupExpenseData expense) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('groupExpenses')
          .add(expense.toMap());
      state = AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
