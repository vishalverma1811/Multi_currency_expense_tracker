import 'package:get/get.dart';
import '../features/expenses/pages/add_edit_expense_page.dart';
import '../features/expenses/pages/expense_list_page.dart';
import '../features/expenses/pages/summary_page.dart';

class Routes {
  static const list = '/';
  static const addEdit = '/add-edit';
  static const summary = '/summary';
}

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.list, page: () => const ExpenseListPage()),
    GetPage(name: Routes.addEdit, page: () => const AddEditExpensePage()),
    GetPage(name: Routes.summary, page: () => const SummaryPage()),
  ];
}
