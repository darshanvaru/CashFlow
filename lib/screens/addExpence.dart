import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';
import '../widgets/AccountPanel.dart';
import '../widgets/CategoryPanel.dart';

class AddExpenseScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? recordData;

  const AddExpenseScreen({
    super.key,
    this.isEditing = false,
    this.recordData,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController displayController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String firstNumber = '', operator = '', transactionType = 'EXPENSE';
  bool shouldResetDisplay = false, calculationCompleted = false, _isLoading = false;
  int selectedCategoryId = 1, fromAccountId = 1, toAccountId = 1;
  String selectedCategory = 'Category', selectedAccount = 'Account', transferAccount = 'Account';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.recordData != null) {

      // Set initial values for editing
      displayController.text = widget.recordData!['amount'].abs().toString();
      noteController.text = widget.recordData!['description'];
      selectedCategoryId = widget.recordData!['category_id'];
      fromAccountId = widget.recordData!['account_id'];

      // Set transaction type based on amount
      if (widget.recordData!['amount'] > 0) {
        transactionType = 'INCOME';
      } else {
        transactionType = 'EXPENSE';
      }

      // Parse date and time
      try {
        // Parse the date (assuming format is "MMM dd, yyyy")
        final dateParts = widget.recordData!['date'].split(' ');
        final month = _getMonthNumber(dateParts[0]);
        final day = int.parse(dateParts[1].replaceAll(',', ''));
        final year = int.parse(dateParts[2]);
        selectedDate = DateTime(year, month, day);

        // Parse the time
        final timeParts = widget.recordData!['time'].split(':');
        selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      } catch (e) {
        print('Error parsing date/time: $e');
      }

      // Fetch and set category and account names
      _fetchCategoryAndAccountNames();
    }
  }

  Future<void> _fetchCategoryAndAccountNames() async {
    try {
      final dbService = DatabaseService.instance;
      final db = await dbService.database;

      // Fetch category name
      final List<Map<String, dynamic>> categories = await db!.query(
        'categories',
        where: 'categorie_id = ?',
        whereArgs: [selectedCategoryId],
      );
      if (categories.isNotEmpty) {
        setState(() {
          selectedCategory = categories.first['name'];
        });
      }

      // Fetch account name
      final List<Map<String, dynamic>> accounts = await db.query(
        'account',
        where: 'account_id = ?',
        whereArgs: [fromAccountId],
      );
      if (accounts.isNotEmpty) {
        setState(() {
          selectedAccount = accounts.first['name'];
        });
      }
    } catch (e) {
      print('Error fetching names: $e');
    }
  }

  int _getMonthNumber(String monthName) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames.indexOf(monthName) + 1;
  }

  // Calculator logic
  void buttonPressed(String value) {
    setState(() {
      if (_isOperator(value)) {
        _handleOperator(value);
      } else if (value == '.') {
        _handleDecimalPoint();
      } else {
        _handleNumber(value);
      }
    });
  }

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == 'x' || value == '/';
  }

  void _handleOperator(String value) {
    calculationCompleted = false;
    if (operator.isEmpty && displayController.text.isNotEmpty) {
      firstNumber = displayController.text;
      operator = value;
      shouldResetDisplay = true;
    } else if (displayController.text.isNotEmpty) {
      calculate();
      firstNumber = displayController.text;
      operator = value;
      shouldResetDisplay = true;
    }
  }

  void _handleDecimalPoint() {
    if (!displayController.text.contains('.')) {
      if (shouldResetDisplay || displayController.text.isEmpty) {
        displayController.text = '0.';
        shouldResetDisplay = false;
      } else {
        displayController.text += '.';
      }
    }
  }

  void _handleNumber(String value) {
    if (calculationCompleted) {
      displayController.text = value;
      calculationCompleted = false;
    } else if (shouldResetDisplay) {
      displayController.text = value;
      shouldResetDisplay = false;
    } else {
      displayController.text += value;
    }
  }

  void calculate() {
    if (firstNumber.isEmpty || operator.isEmpty || displayController.text.isEmpty) {
      return;
    }

    setState(() {
      try {
        double num1 = double.parse(firstNumber);
        double num2 = double.parse(displayController.text);
        double result = 0;

        switch (operator) {
          case '+':
            result = num1 + num2;
            break;
          case '-':
            result = num1 - num2;
            break;
          case 'x':
            result = num1 * num2;
            break;
          case '/':
            if (num2 != 0) {
              result = num1 / num2;
            } else {
              _showError('Cannot divide by zero');
              _resetCalculator();
              return;
            }
            break;
        }

        displayController.text = _formatResult(result);
        firstNumber = '';
        operator = '';
        calculationCompleted = true;
      } catch (e) {
        _showError('Invalid calculation');
        _resetCalculator();
      }
    });
  }

  void _resetCalculator() {
    displayController.text = '';
    firstNumber = '';
    operator = '';
    calculationCompleted = false;
  }

  String _formatResult(double result) {
    if (result == result.truncateToDouble()) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(2);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Date and time formatting
  String formatDate(DateTime date) {
    return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  String _formatDateForDb(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTimeForDb(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _showCategoryPanel() async {
    try {
      final category = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return CategoryPanel(transactionType: transactionType.toLowerCase());
        },
      );

      if (category != null && category.containsKey('name') && category.containsKey('categorie_id')) {
        setState(() {
          selectedCategory = category['name'] as String;
          selectedCategoryId = category['categorie_id'] as int;
        });
      }
    } catch (e) {
      _showError('Error selecting category');
    }
  }

  Future<void> _showAccountPanel({bool isFrom = true}) async {
    try {
      final account = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const AccountPanel();
        },
      );

      if (account != null && account.containsKey('name') && account.containsKey('account_id')) {
        setState(() {
          if (transactionType.toLowerCase() == 'transfer') {
            if (isFrom) {
              selectedAccount = account['name'] as String;
              fromAccountId = account['account_id'] as int;
            } else {
              transferAccount = account['name'] as String;
              toAccountId = account['account_id'] as int;
            }
          } else {
            selectedAccount = account['name'] as String;
            fromAccountId = account['account_id'] as int;
          }
        });
      }
    } catch (e) {
      _showError('Error selecting account');
    }
  }

  bool _validateForm() {
    if (displayController.text.isEmpty) {
      _showError('Please enter an amount');
      return false;
    }

    try {
      double.parse(displayController.text);
    } catch (e) {
      _showError('Invalid amount');
      return false;
    }

    if (selectedCategory == 'Category' && transactionType.toLowerCase() != 'transfer') {
      _showError('Please select a category');
      return false;
    }
    if (selectedAccount == 'Account') {
      _showError('Please select an account');
      return false;
    }
    if (transactionType.toLowerCase() == 'transfer') {
      if (transferAccount == 'Account') {
        _showError('Please select transfer to account');
        return false;
      }
      if (selectedAccount == transferAccount) {
        _showError('Transfer accounts must be different');
        return false;
      }
    }
    return true;
  }

  Future<void> _addRecords() async {
    try {
      setState(() => _isLoading = true);

      final amount = double.parse(displayController.text);
      final description = noteController.text;
      final date = _formatDateForDb(selectedDate);
      final time = _formatTimeForDb(selectedTime);
      final dbService = DatabaseService.instance;

      // Determine the final amount based on transaction type
      double finalAmount;
      if (transactionType.toLowerCase() == 'income') {
        finalAmount = amount;
      } else {
        finalAmount = -amount;
      }

      // Create a map of the record
      final record = {
        'amount': finalAmount,
        'description': description,
        'category_id': selectedCategoryId,
        'account_id': fromAccountId,
        'date': date,
        'time': time,
      };

      if (widget.isEditing) {
        // Update existing record
        final success = await dbService.update(
          'records',
          record,
          where: 'record_id = ?',
          whereArgs: [widget.recordData!['record_id']],
        );

        if (success <= 0) {
          throw Exception('Failed to update record');
        }
      } else {
        // Handle income or expense
        final accountData = await dbService.query(
          'account',
          where: 'account_id = ?',
          whereArgs: [fromAccountId],
        );

        if (accountData.isEmpty) {
          throw Exception('Account not found');
        }

        double currentBalance = accountData.first['balance'] as double;

        if (transactionType.toLowerCase() == 'expense') {
          // Check if account has sufficient balance for expense
          if (currentBalance < amount) {
            throw Exception('Insufficient balance for expense');
          }
          // Update account balance for expense
          await dbService.update(
            'account',
            {'balance': currentBalance - amount},
            where: 'account_id = ?',
            whereArgs: [fromAccountId],
          );
        } else { // income
          // Update account balance for income
          await dbService.update(
            'account',
            {'balance': currentBalance + amount},
            where: 'account_id = ?',
            whereArgs: [fromAccountId],
          );
        }

        // Insert the record
        final recordId = await dbService.insert('records', record);

        if (recordId <= 0) {
          throw Exception('Failed to save record');
        }
      }

      Navigator.pop(context, true); // Return true to trigger refresh
    } catch (e) {
      _showError('Error saving record: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
              children: [
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              children: [
              // Top Bar
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              TextButton(
              onPressed: () => Navigator.pop(context),
      child: const Row(
        children: [
          Icon(Icons.close, color: Colors.teal, size: 30),
          SizedBox(width: 5),
          Text(
            'CANCEL',
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    TextButton(
    onPressed: _isLoading ? null : () {
    if (_validateForm()) {
    _addRecords();
    }
    },
    child: const Row(
    children: [
    Icon(Icons.check, color: Colors.teal, size: 30),
    SizedBox(width: 5),
    Text(
    'SAVE',
    style: TextStyle(
    fontSize: 18,
    color: Colors.teal,
      fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
              ],
              ),

                // Transaction type selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTransactionTypeButton('INCOME'),
                    const SizedBox(width: 10),
                    const Text(" | ", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    _buildTransactionTypeButton('EXPENSE'),
                    const SizedBox(width: 10),
                    const Text(" | ", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    _buildTransactionTypeButton('TRANSFER'),
                  ],
                ),
                const SizedBox(height: 20),

                // Account and category selectors
                Row(
                  children: [
                    Expanded(
                      child: transactionType.toLowerCase() == 'transfer'
                          ? _buildSelectionContainer("From", Icons.credit_card, isFrom: true)
                          : _buildSelectionContainer("Account", Icons.credit_card),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: transactionType.toLowerCase() == 'transfer'
                          ? _buildSelectionContainer("To", Icons.credit_card, isFrom: false)
                          : _buildSelectionContainer("Category", Icons.shopping_cart),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note input
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x83E6DEFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal, width: 2),
                  ),
                  child: TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Add note...',
                    ),
                    maxLines: 6,
                  ),
                ),
                const SizedBox(height: 16),

                // Amount display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        operator,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: displayController,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.backspace_outlined, color: Colors.teal),
                        onPressed: () {
                          setState(() {
                            if (displayController.text.isNotEmpty) {
                              displayController.text = displayController.text.substring(
                                0,
                                displayController.text.length - 1,
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Calculator grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final buttonLabels = [
                        '+', '7', '8', '9',
                        '-', '4', '5', '6',
                        'x', '1', '2', '3',
                        '/', '0', '.', '='
                      ];
                      return _buildCalculatorButton(buttonLabels[index]);
                    },
                  ),
                ),

                // Date and time selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 2920)),
                                lastDate: DateTime.now().add(const Duration(days: 3285)),
                              );

                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Text(
                              formatDate(selectedDate),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "  |  ",
                        style: TextStyle(fontSize: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedTime = picked;
                                });
                              }
                            },
                            child: Text(
                              formatTime(selectedTime),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ),
          ),

                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
          ),
      ),
    );
  }

  Widget _buildTransactionTypeButton(String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          transactionType = type;
          selectedCategory = 'Category';
        });
      },
      child: Row(
        children: [
          if (transactionType == type)
            const Icon(Icons.check_circle, size: 28, color: Colors.teal),
          Text(
            ' $type',
            style: TextStyle(
              fontSize: transactionType == type ? 17 : 14,
              color: transactionType == type ? Colors.black : Colors.grey,
              fontWeight: transactionType == type ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionContainer(String title, IconData icon, {bool? isFrom}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            if (title == 'Category') {
              await _showCategoryPanel();
            } else {
              if (transactionType.toLowerCase() == 'transfer') {
                await _showAccountPanel(isFrom: isFrom ?? true);
              } else {
                await _showAccountPanel();
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.teal, size: 30),
                const SizedBox(width: 8),
                Text(
                  _getDisplayText(title, isFrom),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayText(String title, bool? isFrom) {
    if (title == 'Category') return selectedCategory;
    if (transactionType.toLowerCase() == 'transfer') {
      return isFrom! ? selectedAccount : transferAccount;
    }
    return selectedAccount;
  }

  Widget _buildCalculatorButton(String label) {
    return ElevatedButton(
      onPressed: () {
        if (label == '=') {
          calculate();
        } else {
          buttonPressed(label);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}