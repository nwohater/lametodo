import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<String> getPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return documentsDirectory.path;
  }

  static Future<sql.Database> db() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // Build the path to the database file
    final path = join(documentsDirectory.path, 'todo.db');
    print('path: $path');
    return sql.openDatabase(
      path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        print("...creating a table...");
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toIso8601String()
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    final items = await db.query('items', orderBy: 'id');
    return items;
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    final item =
        await db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
    return item;
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toIso8601String()
    };
    final result =
        await db.update('items', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteAll() async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
