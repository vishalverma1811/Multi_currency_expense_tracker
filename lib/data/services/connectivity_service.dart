import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'sync_service.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final isOnline = false.obs;

  void start() {
    _sub?.cancel();
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      final online = results.any((r) => r != ConnectivityResult.none);
      isOnline.value = online;
      if (online) {
        await Get.find<SyncService>().processQueueIfOnline();
      }
    });

    _connectivity.checkConnectivity().then((r) {
      isOnline.value = r != ConnectivityResult.none;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
