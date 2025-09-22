// NOTE: Ini HANYA skeleton. Implementasikan pakai package BLE pilihanmu.
// Rekomendasi: flutter_reactive_ble atau flutter_blue_plus.
// Service ini fokus ke komunikasi "kecil": kirim perintah / terima ACK.

import 'dart:async';

class BleService {
  // TODO: isi dengan instance plugin BLE
  // final FlutterReactiveBle _ble = FlutterReactiveBle();

  // GATT UUID (GANTI dengan UUID milik ESP32 kamu)
  static const String serviceUuid = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';
  static const String commandCharUuid = 'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY';
  static const String notifyCharUuid = 'ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ';

  // Stream status koneksi dari plugin -> expose ke controller
  Stream<bool> get connection$ {
    // TODO: return stream connected/disconnected dari plugin
    return const Stream.empty();
  }

  Future<void> startScan() async {
    // TODO: scan perangkat "NeuroKit" / filter by service UUID
  }

  Future<void> stopScan() async {
    // TODO
  }

  Future<void> connect(String deviceId) async {
    // TODO: connect & set up notifications
  }

  Future<void> disconnect() async {
    // TODO
  }

  /// Kirim komando ke ESP32 (mis. JSON string -> bytes)
  Future<void> sendCommand(Map<String, dynamic> payload) async {
    // TODO: writeCharacteristicWithoutResponse / WithResponse
    // contoh: final data = utf8.encode(jsonEncode(payload));
  }

  /// Optional: listen notification/ack
  Stream<Map<String, dynamic>> get notifications {
    // TODO: parse notifikasi dari characteristic notify
    return const Stream.empty();
  }
}

/*
// ========== REAL BLE IMPLEMENTATION (flutter_reactive_ble) ==========
import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // GANTI UUID sesuai firmware ESP32 kamu
  static const Uuid _svc  = Uuid.parse('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX');
  static const Uuid _cmdC = Uuid.parse('YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY');
  static const Uuid _ntfC = Uuid.parse('ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ');

  final _connCtrl = StreamController<bool>.broadcast();
  Stream<bool> get connection$ => _connCtrl.stream;

  DiscoveredDevice? _target;
  QualifiedCharacteristic? _cmdChar;
  StreamSubscription<List<int>>? _ntfSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;

  // Notifikasi terparse JSON
  final _notifCtrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notifications => _notifCtrl.stream;

  Future<void> startScan() async {
    // Filter by service UUID, atau by name (“NeuroKit”)
    _ble.scanForDevices(withServices: [_svc]).listen((d) {
      if (_target != null) return;
      // contoh: pilih device pertama yang cocok
      _target = d;
    });
  }

  Future<void> stopScan() async {
    // reactive_ble stop otomatis saat stream close; biarkan
  }

  Future<void> connect(String? deviceId) async {
    final id = deviceId ?? _target?.id;
    if (id == null) return;

    _connSub?.cancel();
    _connSub = _ble
        .connectToDevice(id: id, connectionTimeout: const Duration(seconds: 10))
        .listen((evt) async {
      if (evt.connectionState == DeviceConnectionState.connected) {
        _cmdChar = QualifiedCharacteristic(
          serviceId: _svc, characteristicId: _cmdC, deviceId: id);
        final ntfChar = QualifiedCharacteristic(
          serviceId: _svc, characteristicId: _ntfC, deviceId: id);

        _ntfSub?.cancel();
        _ntfSub = _ble.subscribeToCharacteristic(ntfChar).listen((data) {
          try {
            final m = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
            _notifCtrl.add(m);
          } catch (_) {}
        });

        _connCtrl.add(true);
      } else if (evt.connectionState == DeviceConnectionState.disconnected) {
        _connCtrl.add(false);
      }
    });
  }

  Future<void> disconnect() async {
    await _ntfSub?.cancel();
    await _connSub?.cancel();
    _connCtrl.add(false);
  }

  Future<void> sendCommand(Map<String, dynamic> payload) async {
    if (_cmdChar == null) return;
    final bytes = utf8.encode(jsonEncode(payload));
    await _ble.writeCharacteristicWithResponse(_cmdChar!, value: bytes);
  }
}
// ====================================================================
*/
