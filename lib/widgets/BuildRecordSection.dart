import 'package:flutter/material.dart';

class RecordSection extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const RecordSection({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...transaction['items'].asMap().entries.map<Widget>((entry) {
          final item = entry.value;

          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'], color: Colors.teal, size: 38,),
                title: Text(item['label']),
                subtitle: Text(item['mode']),
                trailing: Text(
                  '₹${item['amount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: item['amount'] < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
