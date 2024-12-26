import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0; // Initially selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Updating selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex, // Set current selected index
      onTap: _onItemTapped, // Update the index on tap
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
          label: 'Budgets',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 2 ? Icons.account_circle : Icons.account_circle_outlined,
            color: Colors.teal,
            size: 35,
          ),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 3 ? Icons.category : Icons.category_outlined,
            color: Colors.teal,
            size: 35,
          ),
          label: 'Categories',
        ),
      ],
    );
  }
}