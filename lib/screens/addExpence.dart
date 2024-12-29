import 'dart:developer';

import 'package:flutter/material.dart';

import '../widgets/AccountPanel.dart';
import '../widgets/CategoryPanel.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController displayController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String firstNumber = '';
  String operator = '';
  String transactionType = 'EXPENSE';
  bool shouldResetDisplay = false;
  bool calculationCompleted = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedCategory = 'Category';
  String selectedAccount = 'Account';
  String transferAccount = 'Account';

  // logic for calc button press
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

  // Main calculation logic
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

  // date and time format
  String formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)}, ${date.year}";
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

  // panel for showing category names
  Future<void> _showCategoryPanel() async {
    try {
      final category = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return CategoryPanel(transactionType: transactionType.toLowerCase());
        },
      );

      if (category != null && category.containsKey('name')) {
        setState(() {
          selectedCategory = category['name'];
        });
      }
    } catch (e) {
      _showError('Error selecting category');
    }
  }

  // panel for showing account names
  Future<void> _showAccountPanel({bool isFrom = true}) async {
    try {
      final account = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const AccountPanel();
        },
      );

      if (account != null && account.containsKey('name')) {
        setState(() {
          if (transactionType.toLowerCase() == 'transfer') {
            if (isFrom) {
              selectedAccount = account['name'];
            } else {
              transferAccount = account['name'];
            }
          } else {
            selectedAccount = account['name'];
          }
        });
      }
    } catch (e) {
      _showError('Error selecting account');
    }
  }

  // Validation before saving
  bool _validateForm() {
    if (displayController.text.isEmpty) {
      _showError('Please enter an amount');
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
    if (transactionType.toLowerCase() == 'transfer' && transferAccount == 'Account') {
      _showError('Please select transfer to account');
      return false;
    }
    if (transactionType.toLowerCase() == 'transfer' &&
        selectedAccount == transferAccount) {
      _showError('Transfer accounts must be different');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              //Top Bar (Cancle, save)
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
                    onPressed: () {
                      if (_validateForm()) {
                        // Implement save logic here
                        Navigator.pop(context);
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

              // transaction type selector
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

              //Account and category selectors
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

              //Note for record
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

              //text field for amount display
              _buildAmountDisplay(),

              //Calculator
              _buildCalculator(),

              //date and time
              _buildDateTimeSelector(),
            ],
          ),
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

  Widget _buildAmountDisplay() {
    return Container(
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
    );
  }

  Widget _buildCalculator() {
    return Expanded(
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
    );
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

  Widget _buildDateTimeSelector() {
    return Padding(
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
    );
  }
}