import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchExpenseDetailsProvider extends AsyncNotifier {
  @override
  Future<void> build() async {}
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchExpenseDetails(
    String identifier,
    String expenseId,
  ) async {
    state = const AsyncLoading();
    try {
      final collection =
          identifier == 'PERSONAL' ? 'personalExpenses' : 'groupExpenses';

      final data =
          await FirebaseFirestore.instance
              .collection(collection)
              .doc(expenseId)
              .get();

      state = const AsyncData(null);
      return data;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final fetchExpenseDetailsProvider =
    AsyncNotifierProvider<FetchExpenseDetailsProvider, void>(
      FetchExpenseDetailsProvider.new,
    );
