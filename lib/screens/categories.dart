import 'package:cashflow/services/ProgressNotification.dart';
import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  // for showing notification of success or failure
  ProgressNotification msj = ProgressNotification();

  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  //CRUD Operations
  //Fetching categories
  Future<void> fetchCategories() async {
    try {
      setState(() => isLoading = true);
      final db = await DatabaseService.instance.database;
      if (db == null) {
        throw Exception("Database not initialized");
      }

      final allCategories = await db.query('categories', orderBy: 'name ASC');

      final incomeCategories =
      allCategories.where((category) => category['type'] == 'income').toList();
      final expenseCategories =
      allCategories.where((category) => category['type'] == 'expense').toList();

      setState(() {
        categories = [
          {'label': 'Income', 'items': incomeCategories},
          {'label': 'Expense', 'items': expenseCategories},
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      msj.showErrorSnackBar("Failed to load categories: $e", context);
    }
  }

  //Adding categories
  Future<void> addCategory(String name, String type) async {
    try {
      final db = await DatabaseService.instance.database;
      if (db == null) {
        throw Exception("Database not initialized");
      }

      final existing = await db.query(
        'categories',
        where: 'name = ? AND type = ?',
        whereArgs: [name, type],
      );

      if (existing.isNotEmpty) {
        throw Exception('Category already exists');
      }

      await db.insert('categories', {
        'name': name,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });
      await fetchCategories();
      msj.showSuccessSnackBar("Category '$name' added successfully!", context);
    } catch (e) {
      msj.showErrorSnackBar("Failed to add category: $e", context);
    }
  }

  //Deleting categories
  Future<void> deleteCategory(int id) async {
    try {
      final db = await DatabaseService.instance.database;
      if (db == null) {
        throw Exception("Database not initialized");
      }

      await db.delete('categories', where: 'category_id = ?', whereArgs: [id]);
      await fetchCategories();
      msj.showSuccessSnackBar("Category deleted successfully!", context);
    } catch (e) {
      msj.showErrorSnackBar("Failed to delete category: $e", context);
    }
  }

  //Updating Categories
  Future<void> editCategory(int id, String newName) async {
    try {
      final db = await DatabaseService.instance.database;
      if (db == null) {
        throw Exception("Database not initialized");
      }

      await db.update(
        'categories',
        {'name': newName},
        where: 'category_id = ?',
        whereArgs: [id],
      );
      await fetchCategories();
      msj.showSuccessSnackBar("Category updated successfully!", context);
    } catch (e) {
      msj.showErrorSnackBar("Failed to edit category: $e", context);
    }
  }

  //DialogBox for editing category
  void _showEditCategoryDialog(int category_id, String currentName) {
    final categoryNameController = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Edit Category",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: categoryNameController,
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final categoryName = categoryNameController.text.trim();
                      editCategory(category_id, categoryName);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //DialogBox for adding category
  void _showAddCategoryDialog() {
    final categoryNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String categoryType = 'income';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: categoryNameController,
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category name is required';
                          }
                          return null;
                        },
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            setDialogState(() => categoryType = 'income');
                          },
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: categoryType == 'income' ? Colors.teal : Colors.grey,
                              fontWeight: categoryType == 'income'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() => categoryType = 'expense');
                          },
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: categoryType == 'expense' ? Colors.teal : Colors.grey,
                              fontWeight: categoryType == 'expense'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final categoryName = categoryNameController.text.trim();
                      addCategory(categoryName, categoryType);
                      Navigator.of(context).pop();
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : categories.isEmpty
          ? const Center(child: Text("No Categories Added"))
          : Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryGroup = categories[index];
            final items = categoryGroup['items'] as List<dynamic>? ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
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
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No categories in this group"),
                  )
                else
                  ...items.map<Widget>((item) {
                    return ListTile(
                      leading: const Icon(Icons.category,
                          color: Colors.teal, size: 38),
                      title: Text(item['name']),
                      subtitle: Text(item['type']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditCategoryDialog(
                              item['category_id'],
                              item['name'],
                            );
                          } else if (value == 'delete') {
                            deleteCategory(item['category_id']);
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
                  }),
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
