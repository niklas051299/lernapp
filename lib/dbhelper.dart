import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

//Datenbank initalisieren,
class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE exam(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        date TEXT,
        prio TEXT,
        art TEXT,
        ects TEXT
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'motivation.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Erstellen neuer Erinnerung
  static Future<int> createList(
      String name,
      String date,
      String prio,
      String art,
      String ects) async {
    final db = await SQLHelper.db();

    //Zuweisung der Inhalte der Erinnerung
    final data = {
      'name': name,
      'date': date,
      'prio': prio,
      'art' : art,
      'ects' :ects
    };
    final id = await db.insert('exam', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // holen aller Erinnerung
  static Future<List<Map<String, dynamic>>> getLists() async {
    final db = await SQLHelper.db();
    return db.query('exam', orderBy: "id");
  }

  // holen einer Erinnerung mit id
  static Future<List<Map<String, dynamic>>> getList(int id) async {
    final db = await SQLHelper.db();
    return db.query('exam', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // updaten einer Erinnerung
  static Future<int> updateList(
      int id,
      String name,
      String date,
      String prio,
      String art,
      String ects) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'date': date,
      'prio': prio,
      'art' : art,
      'ects' : ects
    };

    final result =
    await db.update('exam', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // löschen einer Erinnerung, anhand der id
  static Future<void> deleteList(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("exam", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Error when deleting an exam: $err");
    }
  }
}
