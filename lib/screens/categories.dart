import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch categories from the database
  Future<void> fetchCategories() async {
    final db = await DatabaseService.instance.database;

    // Fetch all categories
    final allCategories = await db!.query('categories');

    // Separate categories into income and expense
    final incomeCategories =
    allCategories.where((category) => category['type'] == 'income').toList();
    final expenseCategories =
    allCategories.where((category) => category['type'] == 'expense').toList();

    // Update state
    setState(() {
      categories = [
        {'label': 'Income', 'items': incomeCategories},
        {'label': 'Expense', 'items': expenseCategories},
      ];
    });
  }

  // Add new category to the database from Pop Up Widget
  Future<void> addCategory(String name, String type) async {
    final db = await DatabaseService.instance.database;

    // Insert new category
    await db!.insert('categories', {
      'name': name,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Refresh list
    fetchCategories();
  }

  // Pop Up Menu
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedType = 'income';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add New Category"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Name Input Field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                  ),
                ),
                const SizedBox(height: 15),
                // Category Type Dropdown
                Row(
                  children: [
                    const Text("Type: ", style: TextStyle(fontSize: 18)),
                    DropdownButton<String>(
                      value: selectedType,
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedType = newValue!;
                        });
                      },
                      items: <String>['income', 'expense']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value[0].toUpperCase() + value.substring(1),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  final categoryName = nameController.text.trim();
                  if (categoryName.isNotEmpty) {
                    addCategory(categoryName, selectedType);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Category '$categoryName' added!")),
                    );
                  }
                },
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
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryGroup = categories[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "${categoryGroup['label']} Categories",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              const Divider(color: Colors.teal, thickness: 1.5),
              ...categoryGroup['items'].map<Widget>((item) {
                return ListTile(
                  leading: const Icon(Icons.category,
                      color: Colors.teal, size: 38),
                  title: Text(item['name']),
                  subtitle: Text(item['type']),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton.extended(
          onPressed: _showAddCategoryDialog,
          backgroundColor: Colors.teal,
          icon: const Icon(Icons.add, color: Colors.white, size: 38),
          label: const Text("Add New Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }
}
