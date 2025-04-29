import 'package:expense_tracker/model/category.dart';
import 'package:flutter/material.dart';

final List<ExpenseCategory> expenseCategories = [
  ExpenseCategory(name: 'Rent', icon: Icons.home, color: Colors.deepPurple),
  ExpenseCategory(
    name: 'Utilities',
    icon: Icons.flash_on,
    color: Colors.orange,
  ),
  ExpenseCategory(
    name: 'Groceries',
    icon: Icons.shopping_cart,
    color: Colors.green,
  ),
  ExpenseCategory(
    name: 'Transportation',
    icon: Icons.directions_car,
    color: Colors.blue,
  ),
  ExpenseCategory(name: 'Insurance', icon: Icons.security, color: Colors.teal),
  ExpenseCategory(
    name: 'Food & Dining',
    icon: Icons.restaurant,
    color: Colors.redAccent,
  ),
  ExpenseCategory(name: 'Entertainment', icon: Icons.movie, color: Colors.pink),
  ExpenseCategory(
    name: 'Shopping',
    icon: Icons.shopping_bag,
    color: Colors.purple,
  ),
  ExpenseCategory(
    name: 'Health & Fitness',
    icon: Icons.fitness_center,
    color: Colors.lime,
  ),
  ExpenseCategory(name: 'Education', icon: Icons.school, color: Colors.indigo),
  ExpenseCategory(
    name: 'Phone & Internet',
    icon: Icons.wifi,
    color: Colors.cyan,
  ),
  ExpenseCategory(
    name: 'Subscriptions',
    icon: Icons.subscriptions,
    color: Colors.brown,
  ),
  ExpenseCategory(name: 'Travel', icon: Icons.flight, color: Colors.blueAccent),
  ExpenseCategory(
    name: 'Vacation',
    icon: Icons.beach_access,
    color: Colors.lightBlue,
  ),
  ExpenseCategory(
    name: 'Gifts',
    icon: Icons.card_giftcard,
    color: Colors.deepOrange,
  ),
  ExpenseCategory(
    name: 'Personal Care',
    icon: Icons.spa,
    color: Colors.pinkAccent,
  ),
  ExpenseCategory(
    name: 'Miscellaneous',
    icon: Icons.more_horiz,
    color: Colors.grey,
  ),
];
