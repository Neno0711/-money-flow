import 'package:money_flow/formulario_ingreso.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DatabaseProvider {
  static final DatabaseProvider db = DatabaseProvider._();
  DatabaseProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'esit.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
  

    await db.execute('''
      CREATE TABLE TransactionModel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      type INTEGER NOT NULL,
      category TEXT NOT NULL);
    ''');
  }

  // ----- Transacciones -----
  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return await db.insert('TransactionModel', t.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('TransactionModel', orderBy: 'date DESC');
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<double> getTotalByType(TransactionType type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM TransactionModel WHERE type = ?',
      [type.index],
    );
    return result.first['total'] as double? ?? 0.0;
  }
  //metodo para actualizar transacciones
  Future<int> updateTransaction(TransactionModel t) async {
    final db = await database;
    return await db.update(
      'TransactionModel',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  //metodo para eliminar transacciones
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('TransactionModel', where: 'id = ?', whereArgs: [id]);
  }
}
