import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';

class AccountPanel extends StatefulWidget {
  const AccountPanel({super.key});

  @override
  AccountPanelState createState() => AccountPanelState();
}

class AccountPanelState extends State<AccountPanel> {
  late Future<List<Map<String, dynamic>>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    _accountsFuture = _fetchCategories(); // Fetch categories on panel initialization
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final dbService = DatabaseService.instance;
    final Account = await dbService.query('account');
    return Account;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Select Account',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // List of categories
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _accountsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Accounts available, add for adding any transaction'));
                }

                final accounts = snapshot.data!;
                return ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, account);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue, width: 1.5),
                              ),
                                child: const Icon(Icons.account_circle, size: 50, color: Colors.blue)
                            ),
                            const SizedBox(width: 16),
                            Text(
                              account['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "₹${account['balance']}",
                              style: TextStyle(
                                fontSize: 18,
                                color: account['balance'] < 0? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
