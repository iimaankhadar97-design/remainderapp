import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE reminders (
  id $idType,
  title $textType,
  description $textNullType,
  dateTime $textType,
  isCompleted $boolType,
  isRepeatDaily $boolType,
  isFlagged $boolType,
  priority $textType
  )
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE reminders ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE reminders ADD COLUMN isFlagged INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE reminders ADD COLUMN priority TEXT NOT NULL DEFAULT "None"');
    }
  }

  Future<Reminder> create(Reminder reminder) async {
    final db = await instance.database;
    final id = await db.insert('reminders', reminder.toMap());
    return reminder.copyWith(id: id);
  }

  Future<Reminder?> readReminder(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'reminders',
      columns: ['id', 'title', 'description', 'dateTime', 'isCompleted', 'isRepeatDaily', 'isFlagged', 'priority'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Reminder.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Reminder>> readAllReminders() async {
    final db = await instance.database;
    const orderBy = 'dateTime ASC';
    final result = await db.query('reminders', orderBy: orderBy);
    return result.map((json) => Reminder.fromMap(json)).toList();
  }

  Future<int> update(Reminder reminder) async {
    final db = await instance.database;

    return db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
