import 'package:flutter/material.dart';
import 'package:cashflow/widgets/BuildRecordSection.dart';
import '../services/DatabaseService.dart';
import 'addExpence.dart';

class Records extends StatefulWidget {
  const Records({super.key});
  @override
  State<Records> createState() => RecordsState();
}

class RecordsState extends State<Records> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _groupedTransactions = {};
  List<String> _sortedDates = [];
  double _expense = 0.0, _income = 0.0, _total = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchTransactions();
    await _calculateSummary();
  }

  Future<void> _calculateSummary() async {
    try {
      final db = await DatabaseService.instance.database;
      if (db == null) throw Exception('Database not initialized');

      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      final monthRecords = await db.query(
        'records',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );

      double monthExpense = 0.0, monthIncome = 0.0;
      for (var record in monthRecords) {
        final amount = record['amount'] as double;
        amount < 0 ? monthExpense += amount.abs() : monthIncome += amount;
      }

      setState(() {
        _expense = monthExpense;
        _income = monthIncome;
        _total = monthIncome - monthExpense;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final db = await DatabaseService.instance.database;
      if (db == null) throw Exception('Database not initialized');

      final records = await db.query(
        'records',
        orderBy: 'date DESC, time DESC',
      );
      final categories = await db.query('categories');
      final accounts = await db.query('account');

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var record in records) {
        final category = categories.firstWhere(
              (c) => c['categorie_id'] == record['category_id'],
          orElse: () => {},
        );
        final account = accounts.firstWhere(
              (a) => a['account_id'] == record['account_id'],
          orElse: () => {},
        );

        if (category.isNotEmpty && account.isNotEmpty) {
          final dateStr = record['date'] as String?;
          if (dateStr == null) continue;

          final date = DateTime.tryParse(dateStr);
          if (date == null) continue;

          final formattedDate = _formatDate(date);

          if (!grouped.containsKey(formattedDate)) {
            grouped[formattedDate] = [];
          }

          grouped[formattedDate]!.add({
            'record_id': record['record_id'],
            'icon': Icons.category,
            'label': category['name'],
            'mode': account['name'],
            'amount': record['amount'],
            'description': record['description'],
            'category_id': category['categorie_id'],
            'account_id': account['account_id'],
            'time': record['time'],
          });
        }
      }

      setState(() {
        _groupedTransactions = grouped;
        _sortedDates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final suffix = (day % 10 == 1 && day != 11)
        ? 'st'
        : (day % 10 == 2 && day != 12)
        ? 'nd'
        : (day % 10 == 3 && day != 13)
        ? 'rd'
        : 'th';
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
    final weekday = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][date.weekday - 1];
    return '${day}${suffix} $month, $weekday';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                          _groupedTransactions = {};
                          _sortedDates = [];
                        });
                        _initializeData();
                      },
                    ),
                    Text(
                      '${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                          _groupedTransactions = {};
                          _sortedDates = [];
                        });
                        _initializeData();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryColumn('EXPENSE', _expense, Colors.red),
                      _buildSummaryColumn('INCOME', _income, Colors.green),
                      _buildSummaryColumn('TOTAL', _total, Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sortedDates.length,
              itemBuilder: (context, dateIndex) {
                final date = _sortedDates[dateIndex];
                final transactions = _groupedTransactions[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "  $date",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            color: Colors.teal,
                            height: 2,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ],
                      ),
                    ),
                    ...transactions.map((transaction) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(
                            isEditing: true,
                            recordData: {
                              'records_id': transaction['record_id'],
                              ...transaction,
                              'date': date,
                            },
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          setState(() {
                            _groupedTransactions = {};
                            _sortedDates = [];
                          });
                          _initializeData();
                        }
                      }),
                      child: RecordSection(transaction: {'items': [transaction]}),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
        ).then((value) {
          if (value == true) {
            setState(() {
              _groupedTransactions = {};
              _sortedDates = [];
            });
            _initializeData();
          }
        }),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildSummaryColumn(String title, double value, Color color) => Column(
    children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Text(
        "₹${value.toStringAsFixed(2)}",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
      ),
    ],
  );

  String _getMonthName(int month) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
}
