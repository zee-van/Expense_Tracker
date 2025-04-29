import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/screens/expense_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyExpensesFilter extends StatefulWidget {
  const MonthlyExpensesFilter({super.key, required this.id, this.identifier});
  final String id;
  final String? identifier;

  @override
  State<MonthlyExpensesFilter> createState() => _MonthlyExpensesFilterState();
}

class _MonthlyExpensesFilterState extends State<MonthlyExpensesFilter> {
  String? _selectedYear;
  String? _selectedMonth;
  Map<int, List<String>> _availableYearsAndMonths = {};

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

  @override
  void initState() {
    super.initState();
    loadAvailableYearsAndMonths();
  }

  Future<void> loadAvailableYearsAndMonths() async {
    final dateMap = await getAvailableYearsAndMonths(widget.id);
    setState(() {
      _availableYearsAndMonths = dateMap;
    });
  }

  Future<Map<int, List<String>>> getAvailableYearsAndMonths(String id) async {
    if (widget.identifier == 'GROUP') {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('groupExpenses')
              .where('groupId', isEqualTo: id)
              .get();

      final Map<int, Set<String>> yearMonthMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();

        final year = date.year;
        final month = DateFormat('MMMM').format(date);

        if (!yearMonthMap.containsKey(year)) {
          yearMonthMap[year] = {};
        }
        yearMonthMap[year]!.add(month);
      }
      return {
        for (var entry in yearMonthMap.entries)
          entry.key:
              entry.value.toList()..sort(
                (a, b) => DateFormat(
                  'MMMM',
                ).parse(a).month.compareTo(DateFormat('MMMM').parse(b).month),
              ),
      };
    }
    final snapshot =
        await FirebaseFirestore.instance
            .collection('personalExpenses')
            .where('userId', isEqualTo: id)
            .get();

    final Map<int, Set<String>> yearMonthMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['date'] as Timestamp;
      final date = timestamp.toDate();

      final year = date.year;
      final month = DateFormat('MMMM').format(date);

      if (!yearMonthMap.containsKey(year)) {
        yearMonthMap[year] = {};
      }
      yearMonthMap[year]!.add(month);
    }
    return {
      for (var entry in yearMonthMap.entries)
        entry.key:
            entry.value.toList()..sort(
              (a, b) => DateFormat(
                'MMMM',
              ).parse(a).month.compareTo(DateFormat('MMMM').parse(b).month),
            ),
    };
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getFilteredExpenses() async {
    if (_selectedYear == null || _selectedMonth == null) return [];
    if (widget.identifier == 'GROUP') {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('groupExpenses')
              .where('groupId', isEqualTo: widget.id)
              .get();

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredExpenses =
          [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();

        final year = date.year;
        final month = DateFormat('MMMM').format(date);

        if (year.toString() == _selectedYear && month == _selectedMonth) {
          filteredExpenses.add(doc);
        }
      }
      return filteredExpenses;
    }
    final snapshot =
        await FirebaseFirestore.instance
            .collection('personalExpenses')
            .where('userId', isEqualTo: widget.id)
            .get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredExpenses =
        [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = data['date'] as Timestamp;
      final date = timestamp.toDate();

      final year = date.year;
      final month = DateFormat('MMMM').format(date);

      if (year.toString() == _selectedYear && month == _selectedMonth) {
        filteredExpenses.add(doc);
      }
    }

    return filteredExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filtered Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedYear,
              hint: const Text('Select Year'),
              items:
                  _availableYearsAndMonths.keys
                      .map(
                        (year) => DropdownMenuItem(
                          value: year.toString(),
                          child: Text(year.toString()),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                  _selectedMonth = null;
                });
              },
            ),
            SizedBox(height: 16),
            if (_selectedYear != null)
              DropdownButton<String>(
                value: _selectedMonth,
                hint: const Text('Select Month'),
                items:
                    _availableYearsAndMonths[int.parse(_selectedYear!)]
                        ?.map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
              ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>
              >(
                future: getFilteredExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No expenses found for this selection.'),
                    );
                  }
                  final filteredExpenses = snapshot.data!;
                  int totalExpenses = 0;

                  for (final expense in filteredExpenses) {
                    int amount = expense.data()['amount'];

                    totalExpenses += amount;
                  }
                  return ListView(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: double.infinity,

                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Expenses\n Rs.$totalExpenses',
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      for (final myExpense in filteredExpenses)
                        ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (ctx) => ExpenseDetails(
                                      expenseDetails: myExpense,
                                    ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            child: Icon(
                              getCategoryIcon(myExpense.data()['category']),
                              color: getCategoryColor(
                                myExpense.data()['category'],
                              ),
                            ),
                          ),
                          title: Text(myExpense.data()['title']),
                          subtitle: Text(
                            myExpense.data()['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rs.${myExpense.data()['amount']}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd').format(
                                  ((myExpense.data()['date']) as Timestamp)
                                      .toDate(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 70),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
