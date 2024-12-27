import 'package:cashflow/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:cashflow/widgets/BuildDateSection.dart';
import 'package:cashflow/widgets/BuildRecordSection.dart';

import 'addExpence.dart';

class Records extends StatefulWidget {

  const Records({super.key});

  @override
  State<Records> createState() => RecordsState();
}

class RecordsState extends State<Records> {

  final DatabaseService _db = DatabaseService.instance;

  //data
  final List<Map<String, dynamic>> transactions = <Map<String, dynamic>>[
    {
      'date': 'Jan 01, Friday',
      'items': [
        {'icon': Icons.coffee, 'label': 'Coffee', 'mode': 'Wallet', 'amount': -15.00},
        {'icon': Icons.local_gas_station, 'label': 'Fuel', 'mode': 'Card', 'amount': -50.00},
        {'icon': Icons.shopping_basket, 'label': 'Groceries', 'mode': 'Wallet', 'amount': -75.00},
        {'icon': Icons.restaurant, 'label': 'Dinner', 'mode': 'Card', 'amount': -120.00},
      ]
    },
    {
      'date': 'Dec 31, Thursday',
      'items': [
        {'icon': Icons.local_bar, 'label': 'Bar', 'mode': 'Card', 'amount': -100.00},
        {'icon': Icons.movie, 'label': 'Cinema', 'mode': 'Wallet', 'amount': -20.00},
        {'icon': Icons.shopping_cart, 'label': 'Online Shopping', 'mode': 'Card', 'amount': -200.00},
      ]
    },
    {
      'date': 'Dec 30, Wednesday',
      'items': [
        {'icon': Icons.fitness_center, 'label': 'Gym Membership', 'mode': 'Card', 'amount': -40.00},
        {'icon': Icons.book, 'label': 'Books', 'mode': 'Wallet', 'amount': -30.00},
        {'icon': Icons.restaurant_menu, 'label': 'Lunch', 'mode': 'Wallet', 'amount': -25.00},
      ]
    },
    {
      'date': 'Dec 29, Tuesday',
      'items': [
        {'icon': Icons.home_repair_service, 'label': 'Repair Service', 'mode': 'Card', 'amount': -150.00},
        {'icon': Icons.cake, 'label': 'Birthday Cake', 'mode': 'Wallet', 'amount': -50.00},
        {'icon': Icons.sports, 'label': 'Sports Equipment', 'mode': 'Card', 'amount': -100.00},
      ]
    },
    {
      'date': 'Dec 28, Monday',
      'items': [
        {'icon': Icons.hotel, 'label': 'Hotel Stay', 'mode': 'Card', 'amount': -300.00},
        {'icon': Icons.train, 'label': 'Train Ticket', 'mode': 'Wallet', 'amount': -80.00},
        {'icon': Icons.flight, 'label': 'Flight Ticket', 'mode': 'Card', 'amount': -500.00},
      ]
    },
    {
      'date': 'Dec 27, Sunday',
      'items': [
        {'icon': Icons.pets, 'label': 'Pet Supplies', 'mode': 'Wallet', 'amount': -60.00},
        {'icon': Icons.local_hospital, 'label': 'Medicine', 'mode': 'Card', 'amount': -45.00},
        {'icon': Icons.bakery_dining, 'label': 'Bakery', 'mode': 'Wallet', 'amount': -20.00},
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
                    DateSection(transaction: transaction),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),

    );
  }
}