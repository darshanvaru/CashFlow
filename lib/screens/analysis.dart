import 'package:flutter/material.dart';

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {

  double expense = 4853.72;
  double income = 8700.00;
  double total = 3846.28;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //Summary Container
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400, // Shadow color
                  blurRadius: 6, // Spread radius
                  offset: const Offset(0, 3), // Offset in X and Y directions
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

          const Expanded(
            child: Placeholder()
          ),
        ],
      ),
    );
  }
}
