import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/routes.dart';
import '../expense_controller.dart';

class ExpenseListPage extends GetView<ExpenseController> {
  const ExpenseListPage({super.key});

  String _money(double a, String c) => '${a.toStringAsFixed(2)} $c';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.summary),
            icon: const Icon(Icons.pie_chart_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.addEdit),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final items = controller.expenses;
        if (items.isEmpty) {
          return const Center(child: Text('No expenses yet. Tap + to add.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final e = items[i];
            return Dismissible(
              key: ValueKey(e.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline),
              ),
              confirmDismiss: (_) async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete?'),
                    content: Text('Delete "${e.title}"?'),
                    actions: [
                      TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
                    ],
                  ),
                );
                return ok ?? false;
              },
              onDismissed: (_) => controller.deleteExpense(e),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                title: Text(e.title),
                subtitle: Text('${e.category.name} • ${DateFormat.yMMMd().format(e.date)}'),
                trailing: Text(_money(e.amount, e.currency)),
                onTap: () => Get.toNamed(Routes.addEdit, arguments: e),
              ),
            );
          },
        );
      }),
    );
  }
}
