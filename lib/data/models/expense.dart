import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  shopping,
  @HiveField(3)
  bills,
  @HiveField(4)
  entertainment,
  @HiveField(5)
  others,
}

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  ExpenseCategory category;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isDeleted;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Expense copyWith({
    String? title,
    double? amount,
    String? currency,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
