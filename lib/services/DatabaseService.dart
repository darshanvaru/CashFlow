import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  // Lazy initialization for the database
  Future<Database?> get database async {
    if (_db != null) return _db;
    _db = await _getDatabase();
    return _db!;
  }

  // Open or create the database
  Future<Database> _getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "cashflow_db.db");
    print("-------------------------------");
    print('Database Path: ${await getDatabasesPath()}');
    print("-------------------------------");


    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create tables for the database schema
        await _createTables(db);
      },
    );
  }

  // Method to create the tables
  Future<void> _createTables(Database db) async {
    // records Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS records (
        records_id INTEGER PRIMARY KEY,
        amount REAL,
        description TEXT,
        category_id INTEGER,
        account_id INTEGER,
        date TEXT,
        time TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(categorie_id),
        FOREIGN KEY (account_id) REFERENCES account(account_id)
      )
    ''');

    // Account Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS account (
        account_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL,
        created_at TEXT
      )
    ''');

    // Categories Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        categorie_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT CHECK(type IN ('income', 'expense')) NOT NULL,
        created_at TEXT
      )
    ''');

    // Budget Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budget (
        budget_id INTEGER PRIMARY KEY,
        categorie_id INTEGER,
        budget_amount REAL,
        spent REAL DEFAULT 0,
        created_at TEXT,
        FOREIGN KEY (categorie_id) REFERENCES categories(categorie_id)
      )
    ''');
  }

  // CRUD Operations

  // Create - Returns Id of created Row
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db!.insert(table, data);
  }

  // Read - Returns a list of maps (row of data)
  Future<List<Map<String, dynamic>>> query(
      String table, {
        String? where,
        List<Object?>? whereArgs,
      }) async {
    final db = await database;
    return await db!.query(table, where: where, whereArgs: whereArgs);
  }

  // Update - Returns No of affected rows
  Future<int> update(
      String table,
      Map<String, dynamic> data, {
        String? where,
        List<Object?>? whereArgs,
      }) async {
    final db = await database;
    return await db!.update(table, data, where: where, whereArgs: whereArgs);
  }

  // Delete - Returns no of row deleted
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db!.delete(table, where: where, whereArgs: whereArgs);
  }
}
