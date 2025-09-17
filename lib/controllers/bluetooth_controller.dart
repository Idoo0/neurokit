import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import '../services/ble_service.dart';

class BluetoothController extends GetxController {
  final BleService _ble;
  BluetoothController(this._ble);

  final isConnected = false.obs;
  final isScanning = false.obs;

  /// Flag internal: user sedang pairing di Settings dan kita akan coba auto-connect
  final _awaitingPairing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _ble.connection$.listen((ok) => isConnected.value = ok);
  }

  /// Buka halaman Bluetooth Settings OS.
  /// Pada iOS akan fallback ke App Settings (kebijakan Apple).
  Future<void> openSystemBluetoothSettings() async {
    _awaitingPairing.value = true;
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } catch (_) {
      await AppSettings.openAppSettings();
    }
    // Kita tidak menunggu apa pun di sini; saat app kembali ke foreground
    // HomeTab akan memanggil onAppResumed() untuk mencoba connect.
  }

  /// Dipanggil saat AppLifecycleState.resumed (dari UI).
  Future<void> onAppResumed() async {
    if (!_awaitingPairing.value || isConnected.value) return;
    _awaitingPairing.value = false;

    // Coba scan & connect ke NeuroKit
    await scanAndConnect();
  }

  /// Implementasi nyata kamu taruh di sini (pakai flutter_reactive_ble / flutter_blue_plus).
  Future<void> scanAndConnect() async {
    if (isConnected.value) return;
    isScanning.value = true;
    try {
      await _ble.startScan();
      // TODO: pilih device id NeuroKit (by name atau service UUID), lalu:
      // await _ble.connect(deviceId);
    } finally {
      isScanning.value = false;
      await _ble.stopScan();
    }
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
  }
}

/*
// ====== ENABLE THIS WHEN DEVICE READY ======
// di method scanAndConnect():
// await _ble.startScan();
// // pilih deviceId berdasarkan nama atau service UUID
// await _ble.connect(null); // null -> pakai _target dari scan
// await _ble.stopScan();
//
// di disconnect():
// await _ble.disconnect();
//
// di sendCommand(json):
// await _ble.sendCommand(json);
// ===========================================
*/
