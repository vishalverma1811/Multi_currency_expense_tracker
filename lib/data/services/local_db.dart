import 'package:hive/hive.dart';
import '../hive_boxes.dart';
import '../models/expense.dart';
import '../models/sync_action.dart';

class LocalDb {
  Box<Expense> get expenseBox => Hive.box<Expense>(HiveBoxes.expenses);
  Box<SyncAction> get queueBox => Hive.box<SyncAction>(HiveBoxes.syncQueue);

  List<Expense> getAllExpenses() {
    final all = expenseBox.values.toList();
    all.sort((a, b) => b.date.compareTo(a.date));
    return all.where((e) => !e.isDeleted).toList();
  }

  Future<void> upsertExpense(Expense e) async {
    await expenseBox.put(e.id, e);
  }

  Future<void> softDeleteExpense(String id) async {
    final e = expenseBox.get(id);
    if (e == null) return;
    await expenseBox.put(id, e.copyWith(isDeleted: true, updatedAt: DateTime.now()));
  }

  Future<void> enqueue(SyncAction action) async {
    await queueBox.put(action.id, action);
  }

  List<SyncAction> getQueue() {
    final list = queueBox.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> removeAction(String actionId) async {
    await queueBox.delete(actionId);
  }

  Future<void> incrementAttempts(String actionId) async {
    final act = queueBox.get(actionId);
    if (act == null) return;
    act.attempts = act.attempts + 1;
    await act.save();
  }
}
