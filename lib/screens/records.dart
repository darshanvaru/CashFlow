import 'package:flutter/material.dart';
import 'package:cashflow/widgets/BuildDateSection.dart';
import 'package:cashflow/widgets/BuildRecordSection.dart';

class Records extends StatefulWidget {

  const Records({super.key});

  @override
  State<Records> createState() => RecordsState();
}

class RecordsState extends State<Records> {

  //data
  final List<Map<String, dynamic>> transactions = <Map<String, dynamic>>[
    {
      'date': 'Jan 03, Sunday',
      'items': [
        {'icon': Icons.shopping_bag, 'label': 'Clothing', 'mode': 'Card', 'amount': -65.55},
        {'icon': Icons.wifi, 'label': 'Broadband bill', 'mode': 'Card', 'amount': -80.00},
        {'icon': Icons.shopping_cart, 'label': 'Shopping', 'mode': 'Card', 'amount': -120.00},
        {'icon': Icons.receipt, 'label': 'Bills', 'mode': 'Wallet', 'amount': -150.60},
      ]
    },
    {
      'date': 'Jan 02, Saturday',
      'items': [
        {'icon': Icons.movie, 'label': 'Entertainment', 'mode': 'Wallet', 'amount': -30.15},
        {'icon': Icons.fastfood, 'label': 'Snacks', 'mode': 'Wallet', 'amount': -55.00},
        {'icon': Icons.health_and_safety, 'label': 'Health', 'mode': 'Card', 'amount': -120.00},
      ]
    }
  ];

  double expense = 4853.72;
  double income = 8700.00;
  double total = 3846.28;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //BODY with summary and actual expense record
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Summary Container
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios),  //left arrow
                    SizedBox(width: 70,),
                    Column(
                      children: [
                        Text(
                          'January, 2021',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(width: 70,),
                    Icon(Icons.arrow_forward_ios),   //right arrow
                  ],
                ),
                const SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      //Expense
                      Column(
                        children: [
                          const Text('EXPENSE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            "₹${expense.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),

                      //Income
                      Column(
                        children: [
                          const Text('INCOME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            "₹${income.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),

                      //Total
                      Column(
                        children: [
                          const Text('TOTAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            "₹${total.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateSection(transaction: transaction), // Use the new widget here
                    RecordSection(transaction: transaction),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      //BOTTOMNAVBAR
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 35,),
      ),
    );
  }
}