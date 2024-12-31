import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List<Map<String, dynamic>> accounts = [];

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  // Fetch accounts from the database
  Future<void> fetchAccounts() async {
    final db = await DatabaseService.instance.database;

    // Fetch all accounts
    final allAccounts = await db!.query('account');

    setState(() {
      accounts = allAccounts;
    });
  }

  // Add new account to the database from Pop Up Widget
  Future<void> addAccount(String name, String balance) async {
    final db = await DatabaseService.instance.database;

    // Insert new account
    await db!.insert('account', {
      'name': name,
      'balance': double.parse(balance),
      'created_at': DateTime.now().toIso8601String(),
    });

    // Refresh list
    fetchAccounts();
  }

  // Pop Up Menu
  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Add New Account",
              style: TextStyle(
                color: Colors.teal,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Account Name Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      labelStyle: const TextStyle(color: Colors.teal),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // Balance Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Initial Balance',
                      labelStyle: const TextStyle(color: Colors.teal),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  final accountName = nameController.text.trim();
                  final accountBalance = balanceController.text.trim();
                  if (accountName.isNotEmpty && double.tryParse(accountBalance) != null) {
                    addAccount(accountName, accountBalance);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Account '$accountName' added!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid input!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accounts",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: accounts.isEmpty
          ? const Center(child: Text("Add Account for any transaction"))
          : ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Shadow position
                ),
              ],
              border: Border.all(
                color: Colors.teal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet,
                  color: Colors.teal, size: 38),
              title: Text(
                account['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "Balance: ₹${account['balance']}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton.extended(
          onPressed: _showAddAccountDialog,
          backgroundColor: Colors.teal,
          icon: const Icon(Icons.add, color: Colors.white, size: 38),
          label: const Text("Add New Account",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }
}
