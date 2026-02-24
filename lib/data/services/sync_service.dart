import 'dart:async';
import 'package:get/get.dart';
import 'local_db.dart';
import 'connectivity_service.dart';
import '../models/sync_action.dart';

class SyncService extends GetxService {
  final LocalDb _db = Get.find<LocalDb>();
  final ConnectivityService _conn = Get.find<ConnectivityService>();

  final isSyncing = false.obs;

  // In this assignment we don't have a real backend,
  // so this just simulates a network call where you would normally
  // send the queued change to your server and resolve any conflicts.
  Future<bool> _sendToServer(SyncAction action) async {
    await Future.delayed(const Duration(milliseconds: 350));
    // Conflict handling example:
    // If action.attempts > 2, treat as "server conflict" and resolve by "client wins".
    // In real world you would compare version/updatedAt.
    return true;
  }

  Future<void> processQueueIfOnline() async {
    if (!_conn.isOnline.value) return;
    if (isSyncing.value) return;

    isSyncing.value = true;
    try {
      final queue = _db.getQueue();
      for (final action in queue) {
        try {
          final ok = await _sendToServer(action);
          if (ok) {
            await _db.removeAction(action.id);
          } else {
            await _db.incrementAttempts(action.id);
          }
        } catch (_) {
          await _db.incrementAttempts(action.id);
          // leave in queue
        }
      }
    } finally {
      isSyncing.value = false;
    }
  }
}
