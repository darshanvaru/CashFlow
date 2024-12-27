import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String transactionType = 'EXPENSE';
  String display = '';
  String firstNumber = '';
  String operator = '';
  bool shouldResetDisplay = false;
  bool calculationCompleted = false;
  final TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Handles button press on calculator
  void buttonPressed(String value) {
    setState(() {
      // If a calculation is completed and a new number is pressed
      if (calculationCompleted && !(value == '+' || value == '-' || value == 'x' || value == '/')) {
        display = '';  // Clear the display
        calculationCompleted = false;
      }

      if (value == '+' || value == '-' || value == 'x' || value == '/') {
        calculationCompleted = false;  // Reset the flag when operator is pressed
        if (operator.isEmpty) {
          firstNumber = display;
          operator = value;
          shouldResetDisplay = true;
          display = '';
        } else {
          calculate();
          firstNumber = display;
          operator = value;
          shouldResetDisplay = true;
          display = '';
        }
      } else {
        if (shouldResetDisplay) {
          display = value;
          shouldResetDisplay = false;
        } else {
          if (value == '.' && display.contains('.')) {
            return;
          }
          display += value;
        }
      }
    });
  }

  // to calculate the operation
  void calculate() {
    if (firstNumber.isEmpty || operator.isEmpty || display.isEmpty) {
      return;
    }

    setState(() {
      try {
        double num1 = double.parse(firstNumber);
        double num2 = double.parse(display);
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
              display = 'Error';
              firstNumber = '';
              operator = '';
              return;
            }
            break;
        }

        display = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);
        firstNumber = '';
        operator = '';  // This will clear the operator after calculation
        calculationCompleted = true;
      } catch (e) {
        display = 'Error';
        firstNumber = '';
        operator = '';
      }
    });
  }

  // Format date and time
  String formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)}, ${date.year}";
  }
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  //canlce button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

                  //Save Button
                  TextButton(
                    onPressed: () {
                      // Save logic
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

              // Transaction Type Selector
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

              // Account and Category Selection
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionContainer("Account", Icons.credit_card, "Card"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectionContainer("Category", Icons.shopping_cart, "Shopping"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Note Input Field
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

              // Amount Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Operator display
                    Text(
                      operator,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Amount display
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.right,
                        controller: TextEditingController(text: display),
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
                          if (display.isNotEmpty) {
                            display = display.substring(0, display.length - 1);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Calculator
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

              // Bottom Date and Time
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
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2025),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(formatDate(selectedDate), style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text("  |  ", style: TextStyle(fontSize: 30),),
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
                          child: Text(formatTime(selectedTime), style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
        });
      },
      child: Row(
        children: [
          if (transactionType == type)
            Icon(Icons.check_circle, size: 28, color: Colors.teal),
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

  Widget _buildSelectionContainer(String title, IconData icon, String text) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ],
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
}