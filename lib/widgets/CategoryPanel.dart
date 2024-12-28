import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';

class CategoryPanel extends StatefulWidget {
  final String transactionType;

  const CategoryPanel({Key? key, required this.transactionType}) : super(key: key);

  @override
  _CategoryPanelState createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<CategoryPanel> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories(); // Fetch categories on panel initialization
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final dbService = DatabaseService.instance;
    final allCategories = await dbService.query('categories'); // Fetch all categories
    print("---------------------------------------");
    print(allCategories);
    print("---------------------------------------");
    final filteredCategories =
    allCategories.where((category) => category['type'] == widget.transactionType).toList();

    print("---------------------------------------");
    print(widget.transactionType);
    print(filteredCategories);
    print("---------------------------------------");

    return filteredCategories;
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
            'Select Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grid of categories
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories available'));
                }

                final categories = snapshot.data!;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, category);
                        print("-----------------------------------");
                        print(category['name']);
                        print("-----------------------------------");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.category, size: 60, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
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
