import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addPersonalExpenseProvider =
    AsyncNotifierProvider<AddPersonalExpenseProvider, void>(
      AddPersonalExpenseProvider.new,
    );

class AddPersonalExpenseProvider extends AsyncNotifier {
  @override
  Future<void> build() async {}

  Future<void> addPersonalExpense(PersonalExpenseData expense) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('personalExpenses')
          .add(expense.toMap());
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
