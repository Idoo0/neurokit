// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';

// === Services & Controllers ===
import 'services/ble_service.dart'; // stub sekarang, real nanti tinggal uncomment
import 'services/audio_service.dart'; // stub sekarang, real nanti tinggal uncomment
import 'services/local_storage_service.dart';
import 'controllers/bluetooth_controller.dart';
import 'controllers/music_controller.dart';
import 'controllers/session_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeurokitApp());
}

class NeurokitApp extends StatelessWidget {
  const NeurokitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // ⬇️ Pastikan semua dependency terdaftar SEBELUM route pertama dibuka
      initialBinding: _CoreBinding(),
      initialRoute: AppRoutes.initRoute,
      getPages: AppRoutes.routes,
    );
  }
}

///
/// Binding inti aplikasi:
/// - Saat ini instansiasi STUB (BleService, AudioService) → aman untuk dev/testing tanpa device.
/// - Nanti, ketika device siap:
///   * Cukup uncomment implementasi nyata di masing-masing service (yang sudah kukasih blok komentar),
///     TANPA perlu mengubah file ini lagi.
///
class _CoreBinding extends Bindings {
  @override
  void dependencies() {
    // Services (permanent agar tetap hidup sepanjang app)
    Get.put<BleService>(BleService(), permanent: true);
    Get.put<AudioService>(AudioService(), permanent: true);
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true); // ⬅️ NEW

    // Controllers yang bergantung pada services di atas
    Get.put<BluetoothController>(
      BluetoothController(Get.find<BleService>()),
      permanent: true,
    );
    Get.put<MusicController>(
      MusicController(Get.find<AudioService>()),
      permanent: true,
    );
    Get.put<SessionController>(
      SessionController(
        bt: Get.find<BluetoothController>(),
        music: Get.find<MusicController>(),
      ),
      permanent: true,
    );
  }
}

