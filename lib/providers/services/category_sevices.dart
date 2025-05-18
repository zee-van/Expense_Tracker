import 'package:expense_tracker/model/category.dart';
import 'package:flutter/material.dart';

class CategoryServices {
  final List<ExpenseCategory> expenseCategories;
  CategoryServices(this.expenseCategories);

  IconData? getCategoryIcon(String categoryName) {
    for (var category in expenseCategories) {
      if (category.name == categoryName) {
        return category.icon;
      }
    }
    return null;
  }

  Color? getCategoryColor(String categoryName) {
    for (var category in expenseCategories) {
      if (category.name == categoryName) {
        return category.color;
      }
    }
    return Colors.grey;
  }
}
