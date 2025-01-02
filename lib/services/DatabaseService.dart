import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  Future<Database?> get database async {
    return _db ??= await _getDatabase();
  }

  Future<Database> _getDatabase() async {
    if (_db != null) return _db!;

    final databasePath = join(await getDatabasesPath(), "cashflow_db.db");

    try {
      _db = await openDatabase(
        databasePath,
        version: 1,
        onCreate: _createTables,
      );
    } catch (e) {
      const SnackBar(content: Text("Error in Getting Database!"));
    }

    return _db!;
  }

  Future<void> _createTables(Database db, int version) async {
    final batch = db.batch();

    // Records table
    batch.execute('''
      CREATE TABLE IF NOT EXISTS records (
        records_id INTEGER PRIMARY KEY,
        amount REAL,
        description TEXT,
        category_id INTEGER,
        account_id INTEGER,
        expense_type TEXT,
        date DATE,
        time TIME,
        FOREIGN KEY (category_id) REFERENCES categories(category_id),
        FOREIGN KEY (account_id) REFERENCES account(account_id)
      )
    ''');

    // Accounts table
    batch.execute('''
      CREATE TABLE IF NOT EXISTS account (
        account_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL,
        created_at TEXT
      )
    ''');

    // Categories table
    batch.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        category_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT CHECK(type IN ('income', 'expense')) NOT NULL,
        created_at TEXT
      )
    ''');

    // Budget table
    batch.execute('''
      CREATE TABLE IF NOT EXISTS budget (
        budget_id INTEGER PRIMARY KEY,
        category_id INTEGER,
        budget_amount REAL,
        spent REAL DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
      )
    ''');

    await batch.commit();

    // Insert default data only if tables are empty
    if ((await db.query('account')).isEmpty) {
      await _insertDefaultAccounts(db);
    }

    if ((await db.query('categories')).isEmpty) {
      await _insertDefaultCategories(db);
    }
  }

  Future<void> _insertDefaultAccounts(Database db) async {
    final timestamp = DateTime.now().toIso8601String();
    final batch = db.batch();

    for (final name in ["Card", "Cash", "Savings"]) {
      batch.insert('account', {
        'name': name,
        'balance': 0.0,
        'created_at': timestamp,
      });
    }

    await batch.commit();
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final timestamp = DateTime.now().toIso8601String();
    final batch = db.batch();

    for (final category in {
      'income': [
        "Salary", "Business", "Investments", "Gifts", "Rental Income",
        "Savings Interest", "Freelancing", "Refunds", "Bonuses", "Other Income"
      ],
      'expense': [
        "Groceries", "Rent", "Utilities", "Transport", "Education",
        "Healthcare", "Entertainment", "Dining Out", "Shopping", "Other Expenses"
      ]
    }.entries) {
      for (final name in category.value) {
        batch.insert('categories', {
          'name': name,
          'type': category.key,
          'created_at': timestamp,
        });
      }
    }

    await batch.commit();
  }

  // CRUD Operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return (await database)!.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return (await database)!.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return (await database)!.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    return (await database)!.delete(table, where: where, whereArgs: whereArgs);
  }
}