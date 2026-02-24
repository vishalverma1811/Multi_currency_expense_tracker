import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/expense.dart';
import '../../data/models/sync_action.dart';
import '../../data/services/currency_api.dart';
import '../../data/services/local_db.dart';
import '../../data/services/sync_service.dart';

class ExpenseController extends GetxController {
  final LocalDb _db = Get.find<LocalDb>();
  final CurrencyApi _currencyApi = Get.find<CurrencyApi>();
  final SyncService _sync = Get.find<SyncService>();

  final _uuid = const Uuid();

  final expenses = <Expense>[].obs;

  final baseCurrency = 'INR'.obs;
  final isLoadingRates = false.obs;

  // Computed values for Summary UI
  final convertedById = <String, double>{}.obs;
  final conversionErrorById = <String, String>{}.obs;

  Worker? _baseCurrencyWorker;

  @override
  void onInit() {
    super.onInit();

    refreshFromDb();

    _baseCurrencyWorker = ever<String>(baseCurrency, (_) {
      recomputeAllConversions();
    });

    recomputeAllConversions();
  }

  @override
  void onClose() {
    _baseCurrencyWorker?.dispose();
    super.onClose();
  }

  void refreshFromDb() {
    expenses.value = _db.getAllExpenses();
    recomputeAllConversions();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String currency,
    required ExpenseCategory category,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final e = Expense(
      id: _uuid.v4(),
      title: title.trim(),
      amount: amount,
      currency: currency,
      category: category,
      date: date,
      updatedAt: now,
    );

    await _db.upsertExpense(e);

    await _db.enqueue(SyncAction(
      id: _uuid.v4(),
      type: SyncActionType.create,
      expenseId: e.id,
      payload: _expensePayload(e),
      createdAt: now,
    ));

    refreshFromDb();
    await _sync.processQueueIfOnline();
  }

  Future<void> updateExpense(
    Expense existing, {
    required String title,
    required double amount,
    required String currency,
    required ExpenseCategory category,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final updated = existing.copyWith(
      title: title.trim(),
      amount: amount,
      currency: currency,
      category: category,
      date: date,
      updatedAt: now,
      isDeleted: false,
    );

    await _db.upsertExpense(updated);

    await _db.enqueue(SyncAction(
      id: _uuid.v4(),
      type: SyncActionType.update,
      expenseId: updated.id,
      payload: _expensePayload(updated),
      createdAt: now,
    ));

    refreshFromDb();
    await _sync.processQueueIfOnline();
  }

  Future<void> deleteExpense(Expense e) async {
    final now = DateTime.now();
    await _db.softDeleteExpense(e.id);

    await _db.enqueue(SyncAction(
      id: _uuid.v4(),
      type: SyncActionType.delete,
      expenseId: e.id,
      payload: {'id': e.id, 'updatedAt': now.toIso8601String()},
      createdAt: now,
    ));

    refreshFromDb();
    await _sync.processQueueIfOnline();
  }

  Map<String, dynamic> _expensePayload(Expense e) => {
        'id': e.id,
        'title': e.title,
        'amount': e.amount,
        'currency': e.currency,
        'category': e.category.name,
        'date': e.date.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
        'isDeleted': e.isDeleted,
      };

  Future<void> recomputeAllConversions() async {
    convertedById.clear();
    conversionErrorById.clear();

    if (expenses.isEmpty) return;

    final base = baseCurrency.value;

    // all currencies we need USD quotes for = (all expense currencies + base)
    final needed = expenses.map((e) => e.currency).toSet()..add(base);

    isLoadingRates.value = true;
    try {
      // One request (cached with TTL) for all needed currencies
      final usdQuotes = await _currencyApi.getUsdQuotes(
        currencies: needed.toList(),
      );

      double? usdTo(String ccy) => usdQuotes[ccy];

      final usdToBase = usdTo(base);
      if (usdToBase == null) {
        throw Exception('Missing USD->$base');
      }

      for (final e in expenses) {
        if (e.currency == base) {
          convertedById[e.id] = e.amount;
          continue;
        }

        final usdToFrom = usdTo(e.currency);
        if (usdToFrom == null) {
          conversionErrorById[e.id] = 'Missing USD->${e.currency}';
          continue;
        }

        // from->base = (USD->base) / (USD->from)
        final fromToBase = usdToBase / usdToFrom;
        convertedById[e.id] = e.amount * fromToBase;
      }
    } catch (err) {
      for (final e in expenses) {
        conversionErrorById[e.id] = err.toString();
      }
    } finally {
      isLoadingRates.value = false;
    }
  }
}