import 'package:flutter/material.dart';

class DateSection extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const DateSection({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 18, top: 15),
          child: Text(
            transaction['date'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),

        // Divider for date
        const Divider(
          color: Colors.teal,
          thickness: 2,
          indent: 10, // left
          endIndent: 10, // right
        )
      ],
    );
  }
}
