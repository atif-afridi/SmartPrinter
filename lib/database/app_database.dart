import 'package:printer_app/database/printer_model.dart';
import 'package:sqflite/sqflite.dart';

import 'printer_connect_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    // final path = '$databasePath/notes.db';
    final path = '$databasePath/smart_printer.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Future<void> _createDatabase(Database db, int version) async {
  //   return await db.execute('''
  //       CREATE TABLE printer (
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         title TEXT NOT NULL,
  //         created_time INTEGER NOT NULL
  //       )
  //     ''');
  // }

  Future<void> _createDatabase(Database db, _) async {
    return await db.execute('''
        CREATE TABLE ${SmartPrinterFields.tableName} (
          ${SmartPrinterFields.id} ${SmartPrinterFields.idType},
          ${SmartPrinterFields.title} ${SmartPrinterFields.textType},
          ${SmartPrinterFields.isConnected} ${SmartPrinterFields.isConnected},
          ${SmartPrinterFields.createdTime} ${SmartPrinterFields.textType}
        )
      ''');
  }

  Future<PrintModel> create(PrintModel note) async {
    final db = await instance.database;
    final id = await db.insert(SmartPrinterFields.tableName, note.toJson());
    return note.copy(id: id);
  }

  Future<PrintModel> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      SmartPrinterFields.tableName,
      columns: SmartPrinterFields.values,
      where: '${SmartPrinterFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PrintModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<PrintModel>> readAll() async {
    final db = await instance.database;
    const orderBy = '${SmartPrinterFields.createdTime} DESC';
    if (db.isOpen) {
      print("db OPEN");
    } else {
      print("db CLOSED");
      await instance.open();
    }
    final result =
        await db.query(SmartPrinterFields.tableName, orderBy: orderBy);
    return result.map((json) => PrintModel.fromJson(json)).toList();
  }

  Future<int> update(PrintModel note) async {
    final db = await instance.database;
    return db.update(
      SmartPrinterFields.tableName,
      note.toJson(),
      where: '${SmartPrinterFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      SmartPrinterFields.tableName,
      where: '${SmartPrinterFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete(SmartPrinterFields.tableName);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future open() async {
    final db = await instance.database;
    if (!db.isOpen) {
      instance.open();
    }
  }
}
