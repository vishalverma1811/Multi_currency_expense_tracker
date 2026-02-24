import 'package:hive/hive.dart';

part 'sync_action.g.dart';

@HiveType(typeId: 3)
enum SyncActionType {
  @HiveField(0)
  create,
  @HiveField(1)
  update,
  @HiveField(2)
  delete,
}

@HiveType(typeId: 2)
class SyncAction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  SyncActionType type;

  @HiveField(2)
  String expenseId;

  @HiveField(3)
  Map<String, dynamic> payload;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int attempts;

  SyncAction({
    required this.id,
    required this.type,
    required this.expenseId,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
  });
}
