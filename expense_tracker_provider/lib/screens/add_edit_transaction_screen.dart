// lib/screens/add_edit_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  // ถ้ามี transaction = แก้ไข
  // ถ้าเป็น null = เพิ่มใหม่
  final MyTransaction? transaction;

  const AddEditTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    // ถ้าเป็นโหมดแก้ไข
    // นำข้อมูลเดิมมาใส่ในฟอร์ม
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text =
          widget.transaction!.amount.toString();

      _selectedDate = widget.transaction!.date;
      _selectedType = widget.transaction!.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // เลือกวันที่
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // บันทึกข้อมูล
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final provider = context.read<TransactionProvider>();

    if (isEditing) {
      // ========================================================
      // กระบวนการ Update
      // ========================================================
      await provider.updateTransaction(
        widget.transaction!.id!,
        MyTransaction(
          title: title,
          amount: amount,
          date: _selectedDate,
          type: _selectedType,
        ),
      );
    } else {
      // ========================================================
      // กระบวนการ Insert
      // ========================================================
      await provider.addTransaction(
        title,
        amount,
        _selectedDate,
        _selectedType,
      );
    }

    // กลับไปหน้าก่อนหน้า
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการ',
        ),
      ),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // ==================================================
              // ชื่อรายการ
              // ==================================================
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อรายการ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อรายการ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // จำนวนเงิน
              // ==================================================
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'จำนวนเงิน',
                  suffixText: 'บาท',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกจำนวนเงิน';
                  }

                  final amount = double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return 'กรุณากรอกจำนวนเงินให้ถูกต้อง';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // ประเภท รายรับ / รายจ่าย
              // ==================================================
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'ประเภท',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('รายรับ'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('รายจ่าย'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // วันที่
              // ==================================================
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('วันที่'),
                subtitle: Text(
                  '${_selectedDate.day}/'
                  '${_selectedDate.month}/'
                  '${_selectedDate.year}',
                ),
                trailing: ElevatedButton(
                  onPressed: _selectDate,
                  child: const Text('เลือกวันที่'),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // ปุ่มบันทึก
              // ==================================================
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text(
                    isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
