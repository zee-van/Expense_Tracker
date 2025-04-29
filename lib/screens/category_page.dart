import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/screens/expense_with_category.dart';
import 'package:flutter/material.dart';

class CategoryPageScreen extends StatefulWidget {
  const CategoryPageScreen({super.key});

  @override
  State<CategoryPageScreen> createState() => _CategoryPageScreenState();
}

class _CategoryPageScreenState extends State<CategoryPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          for (final category in expenseCategories)
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (ctx) =>
                            ExpenseWithCategoryScreen(category: category.name),
                  ),
                );
              },
              leading: CircleAvatar(
                child: Icon(category.icon, color: category.color),
              ),
              title: Text(category.name),
            ),
        ],
      ),
    );
  }
}
