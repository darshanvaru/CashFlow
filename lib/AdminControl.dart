import 'package:flutter/material.dart';
import '../services/DatabaseService.dart';

class AdminControl extends StatefulWidget {
  const AdminControl({super.key});

  @override
  State<AdminControl> createState() => _AdminControlState();
}

class _AdminControlState extends State<AdminControl> {
  String? selectedTable;
  List<String> tables = [];
  List<Map<String, dynamic>> tableData = [];
  final tableNameController = TextEditingController();
  final columnNameController = TextEditingController();
  final columnTypeController = TextEditingController();
  List<String> columnNames = []; // Store column names for the selected table
  List<TextEditingController> fieldControllers = []; // Controllers for dynamic fields

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  // Fetch the list of all tables in the database
  Future<void> fetchTables() async {
    final db = await DatabaseService.instance.database;
    final result = await db!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    setState(() {
      tables = result.map((row) => row['name'] as String).toList();
    });
  }

  // Fetch data from the selected table
  Future<void> fetchTableData() async {
    if (selectedTable == null) return;

    final db = await DatabaseService.instance.database;
    try {
      final data = await db!.query(selectedTable!);
      setState(() {
        tableData = data;
      });
    } catch (e) {
      setState(() {
        tableData = [];
      });
    }
  }

  // Fetch column names for the selected table
  Future<void> fetchColumns() async {
    if (selectedTable == null) return;

    final db = await DatabaseService.instance.database;
    final result = await db!.rawQuery(
      "PRAGMA table_info($selectedTable);",
    );

    setState(() {
      columnNames = result.map((row) => row['name'] as String).toList();
      fieldControllers = List.generate(columnNames.length, (_) => TextEditingController());
    });
  }

  // Insert data into the selected table
  Future<void> insertData(Map<String, String> data) async {
    final db = await DatabaseService.instance.database;
    try {
      await db!.insert(selectedTable!, data);
      fetchTableData(); // Refresh the data after insertion
    } catch (e) {
      print("Error inserting data into $selectedTable: $e");
    }
  }

  // Show dialog to insert data into the selected table
  void showInsertDataDialog() {
    if (selectedTable == null || columnNames.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Insert Data"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(columnNames.length, (index) {
                    return TextField(
                        controller: fieldControllers[index],
                        decoration: InputDecoration(
                          labelText: columnNames[index],
                        ),
                      );
                    }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Map<String, String> data = {};
                    for (int i = 0; i < columnNames.length; i++) {
                      // Avoid adding 'created_at' to the data since it's pre-filled
                      if (columnNames[i] != 'created_at') {
                        data[columnNames[i]] = fieldControllers[i].text;
                      }
                    }
                    insertData(data); // Insert the data into the selected table
                    Navigator.pop(context);
                  },
                  child: const Text("Insert Data"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add a new table to the database
  Future<void> addTable(String name, Map<String, String> columns) async {
    final db = await DatabaseService.instance.database;
    final columnDefinitions =
    columns.entries.map((e) => "${e.key} ${e.value}").join(', ');
    await db!.execute('CREATE TABLE IF NOT EXISTS $name ($columnDefinitions)');
    fetchTables();
  }

  // Show dialog to add a new table
  void showAddTableDialog() {
    final Map<String, String> columns = {};
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Table"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tableNameController,
                    decoration: const InputDecoration(labelText: "Table Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: columnNameController,
                    decoration: const InputDecoration(labelText: "Column Name"),
                  ),
                  TextField(
                    controller: columnTypeController,
                    decoration: const InputDecoration(
                        labelText: "Column Type (e.g., TEXT, INTEGER)"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (columnNameController.text.isNotEmpty &&
                          columnTypeController.text.isNotEmpty) {
                        columns[columnNameController.text] =
                            columnTypeController.text;
                        setDialogState(() {});
                        columnNameController.clear();
                        columnTypeController.clear();
                      }
                    },
                    child: const Text("Add Column"),
                  ),
                  const SizedBox(height: 10),
                  if (columns.isNotEmpty)
                    ...columns.entries.map((e) => Text("${e.key}: ${e.value}")),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final tableName = tableNameController.text.trim();
                    if (tableName.isNotEmpty && columns.isNotEmpty) {
                      addTable(tableName, columns);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create Table"),
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
      appBar: AppBar(
        title: const Text("Admin Control"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Table Selection Dropdown
            Row(
              children: [
                const Text("Select Table", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedTable,
                  hint: const Text("Select Table"),
                  onChanged: (value) {
                    setState(() {
                      selectedTable = value;
                      fetchColumns(); // Fetch columns when table is selected
                    });
                    fetchTableData();
                  },
                  items: tables
                      .map((table) => DropdownMenuItem<String>(
                    value: table,
                    child: Text(table),
                  ))
                      .toList(),
                ),
              ],
            ),
            // Buttons for Adding Table, Inserting Data, and Viewing Data
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: showAddTableDialog,
                    child: const Text("Add Table"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedTable != null) {
                        fetchTableData();
                      }
                    },
                    child: const Text("View Table"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: showInsertDataDialog,
                    child: const Text("Insert Data"),
                  ),
                ),
              ],
            ),

            // Expanded widget to show the data dynamically
            Expanded(
              child: tableData.isNotEmpty
                  ? ListView.builder(
                itemCount: tableData.length,
                itemBuilder: (context, index) {
                  final row = tableData[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: row.entries.map((entry) {
                        return Text("${entry.key}: ${entry.value}");
                      }).toList(),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text("No data available in this table."),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
