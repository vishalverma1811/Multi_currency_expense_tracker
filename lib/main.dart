import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'data/hive_boxes.dart';
import 'data/models/expense.dart';
import 'data/models/sync_action.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/currency_api.dart';
import 'data/services/local_db.dart';
import 'data/services/sync_service.dart';
import 'features/expenses/expense_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(SyncActionAdapter());
  Hive.registerAdapter(SyncActionTypeAdapter());

  await Hive.openBox<Expense>(HiveBoxes.expenses);
  await Hive.openBox<SyncAction>(HiveBoxes.syncQueue);

  Get.put(LocalDb());
  Get.put(CurrencyApi(
    apiKey: const String.fromEnvironment('EXCHANGE_RATE_API_KEY', defaultValue: '119f9f3c64ebdbcaa561abb3ba87d5f7'),
  ));
  Get.put(ConnectivityService());
  Get.put(SyncService());

  Get.put(ExpenseController());

  // Start listening network + attempt sync.
  Get.find<ConnectivityService>().start();
  await Get.find<SyncService>().processQueueIfOnline();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.light,
      initialRoute: Routes.list,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}