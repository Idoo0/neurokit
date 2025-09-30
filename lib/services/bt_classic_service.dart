// lib/services/bt_classic_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';

class BtClassicService extends GetxService {
  final isConnected = false.obs;
  final isDiscovering = false.obs;
  final connectedDevice = Rxn<BluetoothDevice>();
  BluetoothConnection? _conn;
  final _lineStream = StreamController<String>.broadcast();
  Stream<String> get lines$ => _lineStream.stream;

  bool logIo = true;

  Future<void> connectDirect({required String address}) async {
    await disconnect();

    // pastikan BT ON
    final on = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    if (!on) await FlutterBluetoothSerial.instance.requestEnable();

    // pastikan bonded
    try {
      final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();
      final ok = bonded.any((d) => d.address == address);
      if (!ok) {
        await FlutterBluetoothSerial.instance.bondDeviceAtAddress(address);
      }
    } catch (_) {}

    // connect RFCOMM
    _conn = await BluetoothConnection.toAddress(address);
    isConnected.value = true;

    _conn!.input?.listen(
      (data) {
        final text = utf8.decode(data);
        if (logIo) debugPrint('← $text');
        for (final line in const LineSplitter().convert(text)) {
          final t = line.trim();
          if (t.isNotEmpty) _lineStream.add(t);
        }
      },
      onDone: () {
        isConnected.value = false;
        connectedDevice.value = null;
        _conn = null;
      },
      onError: (_) {
        isConnected.value = false;
        connectedDevice.value = null;
        _conn = null;
      },
    );
  }

  Future<void> sendLine(String line) async {
    if (_conn == null) throw Exception('Belum terhubung');
    final payload = line.endsWith('\n') ? line : '$line\n';
    if (logIo) debugPrint('→ $payload');
    _conn!.output.add(utf8.encode(payload));
    await _conn!.output.allSent;
  }

  Future<void> disconnect() async {
    try {
      await _conn?.close();
      _conn?.dispose();
    } catch (_) {}
    _conn = null;
    isConnected.value = false;
    connectedDevice.value = null;
  }

  @override
  void onClose() {
    _lineStream.close();
    super.onClose();
  }
}
