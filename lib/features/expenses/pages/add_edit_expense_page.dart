import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/expense.dart';
import '../expense_controller.dart';
import '../widgets/animated_category_picker.dart';

class AddEditExpensePage extends StatefulWidget {
  const AddEditExpensePage({super.key});

  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  final controller = Get.find<ExpenseController>();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;

  Expense? editing;
  ExpenseCategory _category = ExpenseCategory.others;
  DateTime _date = DateTime.now();
  String _currency = 'INR';

  final _currencies = const ['INR', 'USD', 'EUR', 'GBP', 'JPY', 'AED'];

  @override
  void initState() {
    super.initState();
    editing = Get.arguments as Expense?;

    _title = TextEditingController(text: editing?.title ?? '');
    _amount = TextEditingController(text: editing?.amount.toString() ?? '');
    _category = editing?.category ?? ExpenseCategory.others;
    _date = editing?.date ?? DateTime.now();
    _currency = editing?.currency ?? 'INR';
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final title = _title.text;
    final amount = double.parse(_amount.text);

    if (editing == null) {
      await controller.addExpense(
        title: title,
        amount: amount,
        currency: _currency,
        category: _category,
        date: _date,
      );
    } else {
      await controller.updateExpense(
        editing!,
        title: title,
        amount: amount,
        currency: _currency,
        category: _category,
        date: _date,
      );
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Expense' : 'Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final x = double.tryParse(v ?? '');
                if (x == null || x <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _currency,
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'INR'),
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(DateFormat.yMMMd().format(_date)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Pick'),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text('Category'),
            const SizedBox(height: 10),
            AnimatedCategoryPicker(
              selected: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}