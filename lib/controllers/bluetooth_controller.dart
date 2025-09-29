import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import '../services/bt_classic_service.dart';

class BluetoothController extends GetxController {
  final BtClassicService bt;
  BluetoothController(this.bt);

  RxBool get isConnected => bt.isConnected;
  RxBool get isDiscovering => bt.isDiscovering;

  // Beberapa versi app_settings tidak punya openBluetoothSettings.
  // Gunakan openAppSettings sebagai fallback universal.
  Future<void> openSettings() async => AppSettings.openAppSettings();

  Future<void> scanAndConnect() async {
    await bt.connect();
  }

  Future<void> disconnect() => bt.disconnect();

  Future<void> sendLine(String line) => bt.sendLine(line);
}
