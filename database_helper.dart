import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT NOT NULL,
            address TEXT NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Add Contact
  Future<int> insertContact(Contact contact) async {
    final db = await database;

    final data = contact.toMap();
    data.remove('id');

    return await db.insert('contacts', data);
  }

  // Get All Contacts + Search + Favorite
  Future<List<Contact>> getContacts({
    String search = '',
    bool favoritesOnly = false,
  }) async {
    final db = await database;

    String? where;
    List<dynamic> whereArgs = [];

    if (search.isNotEmpty) {
      where = 'name LIKE ?';
      whereArgs.add('%$search%');
    }

    if (favoritesOnly) {
      where = where == null
          ? 'isFavorite = ?'
          : '$where AND isFavorite = ?';

      whereArgs.add(1);
    }

    final result = await db.query(
      'contacts',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id DESC',
    );

    return result.map((e) => Contact.fromMap(e)).toList();
  }

  // Update Contact
  Future<int> updateContact(Contact contact) async {
    final db = await database;

    final data = contact.toMap();
    data.remove('id');

    return await db.update(
      'contacts',
      data,
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete Contact
  Future<int> deleteContact(int id) async {
    final db = await database;

    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}