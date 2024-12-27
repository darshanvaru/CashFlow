import 'package:cashflow/screens/accounts.dart';
import 'package:cashflow/screens/analysis.dart';
import 'package:cashflow/screens/budget.dart';
import 'package:cashflow/screens/categories.dart';
import 'package:cashflow/screens/records.dart';
import 'package:flutter/material.dart';

import 'AdminControl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Records(), // Records Screen
    const Analysis(), // Analysis Screen
    const Budget(), // Budgets Screen
    const Accounts(), // Accounts Screen
    const Categories(), // Categories Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //Global Appbar for all Screen
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('CashFlow'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CashFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Manage your finances',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.teal),
              title: const Text('Admin Control'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminControl()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.teal),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer and return to home
              },
            ),
          ],
        ),
      ),


      //Body with dynamic pages
      body: _pages[_selectedIndex],

      //Global Bottom nav bar for all screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Prevent the enlarging effect
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 0 ? Icons.receipt : Icons.receipt_outlined,
              color: Colors.teal,
              size: 35,
            ),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
              color: Colors.teal,
              size: 35,
            ),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
              color: Colors.teal,
              size: 35,
            ),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3 ? Icons.account_circle : Icons.account_circle_outlined,
              color: Colors.teal,
              size: 35,
            ),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 4 ? Icons.category : Icons.category_outlined,
              color: Colors.teal,
              size: 35,
            ),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}
