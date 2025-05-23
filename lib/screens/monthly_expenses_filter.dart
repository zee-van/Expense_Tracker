import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/providers/categries_colors_icons.dart';
import 'package:expense_tracker/screens/expense_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MonthlyExpensesFilter extends ConsumerStatefulWidget {
  const MonthlyExpensesFilter({super.key, required this.id, this.identifier});
  final String id;
  final String? identifier;

  @override
  ConsumerState<MonthlyExpensesFilter> createState() =>
      _MonthlyExpensesFilterState();
}

class _MonthlyExpensesFilterState extends ConsumerState<MonthlyExpensesFilter> {
  String? _selectedYear;
  String? _selectedMonth;
  Map<int, List<String>> _availableYearsAndMonths = {};

  @override
  void initState() {
    super.initState();
    loadAvailableYearsAndMonths();
  }

  Future<void> loadAvailableYearsAndMonths() async {
    final dateMap = await getAvailableYearsAndMonths(widget.id);
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = DateFormat('MMMM').format(now);

    setState(() {
      _availableYearsAndMonths = dateMap;

      // Automatically select current year if available
      if (_availableYearsAndMonths.containsKey(currentYear)) {
        _selectedYear = currentYear.toString();

        // Automatically select current month if it's in the list
        if (_availableYearsAndMonths[currentYear]!.contains(currentMonth)) {
          _selectedMonth = currentMonth;
        } else {
          // Select first available month if current isn't present
          _selectedMonth = _availableYearsAndMonths[currentYear]!.first;
        }
      } else if (_availableYearsAndMonths.isNotEmpty) {
        // Fallback: pick the most recent available year and its first month
        final recentYear = _availableYearsAndMonths.keys.last;
        _selectedYear = recentYear.toString();
        _selectedMonth = _availableYearsAndMonths[recentYear]!.first;
      }
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
    final categoryServices = ref.watch(categoryServiceProvider);
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
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(30),
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
                                  'Total Expenses',
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                                Text(
                                  'Rs. $totalExpenses',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge!.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      for (final myExpense in filteredExpenses)
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: ListTile(
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
                                categoryServices.getCategoryIcon(
                                  myExpense.data()['category'],
                                ),
                                color: categoryServices.getCategoryColor(
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
