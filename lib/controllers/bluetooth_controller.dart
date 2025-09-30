// lib/controllers/bluetooth_controller.dart
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import '../services/bt_classic_service.dart';
import '../utils/constants.dart';

class BluetoothController extends GetxController {
  final BtClassicService bt;
  BluetoothController(this.bt);

  RxBool get isConnected => bt.isConnected;
  RxBool get isDiscovering => bt.isDiscovering;

  Future<void> scanAndConnect() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    final on = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    if (!on) await FlutterBluetoothSerial.instance.requestEnable();
    await bt.connectDirect(address: BtConstants.MAC_ADDRESS);
  }

  Future<void> disconnect() => bt.disconnect();
  Future<void> sendLine(String s) => bt.sendLine(s);
}
