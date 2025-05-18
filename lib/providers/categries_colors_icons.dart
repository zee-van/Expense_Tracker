import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/model/category.dart';
import 'package:expense_tracker/providers/services/category_sevices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseCategoriesProvider = Provider<List<ExpenseCategory>>((ref) {
  return expenseCategories;
});

final categoryServiceProvider = Provider<CategoryServices>((ref) {
  final categories = ref.watch(expenseCategoriesProvider);
  return CategoryServices(categories);
});
