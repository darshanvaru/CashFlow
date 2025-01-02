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

  Future<void> fetchCategories() async {
    final db = await DatabaseService.instance.database;
    final allCategories = await db!.query('categories');

    final incomeCategories =
    allCategories.where((category) => category['type'] == 'income').toList();
    final expenseCategories =
    allCategories.where((category) => category['type'] == 'expense').toList();

    setState(() {
      categories = [
        {'label': 'Income', 'items': incomeCategories},
        {'label': 'Expense', 'items': expenseCategories},
      ];
    });
  }

  Future<void> addCategory(String name, String type) async {
    final db = await DatabaseService.instance.database;
    await db!.insert('categories', {
      'name': name,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    });
    fetchCategories();
  }

  Future<void> editCategory(int categorie_id, String newName) async {
    final db = await DatabaseService.instance.database;
    await db!.update(
      'categories',
      {'name': newName},
      where: 'categorie_id = ?',
      whereArgs: [categorie_id],
    );
    fetchCategories();
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedType = 'income';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Add New Category",
              style: TextStyle(
                color: Colors.teal,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedType = 'income';
                        });
                      },
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: selectedType == 'income' ? Colors.teal : Colors.grey,
                          fontWeight: selectedType == 'income'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedType = 'expense';
                        });
                      },
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: selectedType == 'expense' ? Colors.teal : Colors.grey,
                          fontWeight: selectedType == 'expense'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
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

  void _showEditCategoryDialog(int categorie_id, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Category"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  editCategory(categorie_id, newName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCategory(int categorie_id) async {
    final db = await DatabaseService.instance.database;
    var debug = await db!.delete(
      'categories',
      where: 'categorie_id = ?',
      whereArgs: [categorie_id],
    );
    SnackBar(
      content: Text("$debug Category deleted"),
    );
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryGroup = categories[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    leading: const Icon(Icons.category, color: Colors.teal, size: 38),
                    title: Text(item['name']),
                    subtitle: Text(item['type']),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCategoryDialog(item['categorie_id'], item['name']);
                        } else if (value == 'delete') {
                          deleteCategory(item['categorie_id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton.extended(
          onPressed: _showAddCategoryDialog,
          backgroundColor: Colors.teal,
          icon: const Icon(Icons.add, color: Colors.white, size: 38),
          label: const Text(
            "Add New Category",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
