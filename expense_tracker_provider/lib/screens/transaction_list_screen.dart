// lib/screens/transaction_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../models/my_transaction.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายรับ-รายจ่าย'),
      ),

      // แสดงรายการทั้งหมดจาก Provider
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          // ถ้าไม่มีรายการ
          if (txProvider.transactions.isEmpty) {
            return const Center(
              child: Text('ไม่มีรายการ'),
            );
          }

          // แสดงรายการธุรกรรม
          return ListView.builder(
            itemCount: txProvider.transactions.length,
            itemBuilder: (ctx, i) {
              final tx = txProvider.transactions[i];

              return ListTile(
                // ประเภท รายรับ / รายจ่าย
                leading: CircleAvatar(
                  child: Text(
                    tx.type == TransactionType.income
                        ? 'รับ'
                        : 'จ่าย',
                  ),
                ),

                // ชื่อรายการ
                title: Text(tx.title),

                // วันที่
                subtitle: Text(
                  DateFormat.yMMMd().format(tx.date),
                ),

                // จำนวนเงิน + ปุ่มลบ
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${tx.amount.toStringAsFixed(2)} บาท',
                      style: TextStyle(
                        color: tx.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    // ปุ่มลบ
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        context
                            .read<TransactionProvider>()
                            .deleteTransaction(tx.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ========================================================
      // ปุ่มเพิ่มรายการ
      // ========================================================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<TransactionProvider>().addTransaction(
                'ค่าอาหาร',
                120.0,
                DateTime.now(),
                TransactionType.expense,
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
