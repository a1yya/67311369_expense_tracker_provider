// lib/providers/transaction_provider.dart

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/my_transaction.dart';

class TransactionProvider with ChangeNotifier {
  static const String _dbName = 'expenses.db';
  static const String _tableName = 'transactions';

  Database? _database;

  // ต้องเป็น MyTransaction ไม่ใช่ Transaction
  List<MyTransaction> _transactions = [];

  // ส่งข้อมูลให้ UI
  List<MyTransaction> get transactions => [..._transactions];

  // โหลดข้อมูลเมื่อ Provider ถูกสร้าง
  TransactionProvider() {
    fetchAndSetTransactions();
  }

  // ============================================================
  // กระบวนการที่ 2: การสร้างฐานข้อมูล
  // ============================================================
  Future<void> _initDatabase() async {
    if (_database != null) return;

    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          print('Creating table $_tableName...');

          return db.execute(
            'CREATE TABLE $_tableName('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title TEXT, '
            'amount REAL, '
            'date TEXT, '
            'type TEXT'
            ')',
          );
        },
      );

      print('Database initialized at $path');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  // ============================================================
  // กระบวนการที่ 3: การ Insert
  // ============================================================
  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type,
  ) async {
    await _initDatabase();

    if (_database == null) return;

    final newTransaction = MyTransaction(
      title: title,
      amount: amount,
      date: date,
      type: type,
    );

    final id = await _database!.insert(
      _tableName,
      newTransaction.toMap(),
    );

    print('Inserted transaction with id: $id');

    // โหลดข้อมูลใหม่หลังเพิ่มรายการ
    await fetchAndSetTransactions();
  }

  // ============================================================
  // กระบวนการที่ 4: การ Read
  // ============================================================
  Future<void> fetchAndSetTransactions() async {
    await _initDatabase();

    if (_database == null) return;

    try {
      // ดึงข้อมูลทั้งหมดจากฐานข้อมูล
      // เรียงจากวันที่ใหม่ไปเก่า
      final dataList = await _database!.query(
        _tableName,
        orderBy: 'date DESC',
      );

      // แปลงข้อมูลจาก Map เป็น MyTransaction
      _transactions = dataList
          .map((item) => MyTransaction.fromMap(item))
          .toList();

      print('Fetched ${_transactions.length} transactions.');

      // แจ้ง UI ให้วาดใหม่
      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  // ============================================================
  // กระบวนการที่ 5: การ Update
  // ============================================================
  Future<void> updateTransaction(
    int id,
    MyTransaction newTransaction,
  ) async {
    await _initDatabase();

    if (_database == null) return;

    await _database!.update(
      _tableName,
      newTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    print('Updated transaction with id: $id');

    // โหลดข้อมูลใหม่หลังแก้ไข
    await fetchAndSetTransactions();
  }

  // ============================================================
  // กระบวนการที่ 6: การ Delete
  // ============================================================
  Future<void> deleteTransaction(int id) async {
    await _initDatabase();

    if (_database == null) return;

    await _database!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    print('Deleted transaction with id: $id');

    // โหลดข้อมูลใหม่หลังลบ
    await fetchAndSetTransactions();
  }
}
