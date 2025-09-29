import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../utils/constants.dart';

class BtClassicService extends GetxService {
  final isConnected = false.obs;
  final isDiscovering = false.obs;
  final connectedDevice = Rxn<BluetoothDevice>();

  // Backwards compatibility alias (some UI references isScanning)
  RxBool get isScanning => isDiscovering;

  BluetoothConnection? _conn;
  StreamSubscription<BluetoothDiscoveryResult>? _scanSub;

  final _lineStream = StreamController<String>.broadcast();
  Stream<String> get lines$ => _lineStream.stream;

  Future<List<BluetoothDevice>> bondedDevices() async {
    return FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<BluetoothDevice?> discoverFirstMatching({
    String nameHint = BtConstants.deviceNameHint,
  }) async {
    if (isDiscovering.value) return null;
    isDiscovering.value = true;
    final c = Completer<BluetoothDevice?>();

    _scanSub = FlutterBluetoothSerial.instance.startDiscovery().listen(
      (r) async {
        if (r.device.name != null &&
            r.device.name!.toUpperCase().contains(nameHint.toUpperCase())) {
          if (!c.isCompleted) {
            c.complete(r.device);
            // stop discovery early once we found a match
            await _scanSub?.cancel();
            _scanSub = null;
            isDiscovering.value = false;
          }
        }
      },
      onDone: () {
        if (!c.isCompleted) c.complete(null);
        isDiscovering.value = false;
      },
    );

    final dev = await c.future;
    await _scanSub?.cancel();
    _scanSub = null;
    isDiscovering.value = false;
    return dev;
  }

  Future<void> connect({BluetoothDevice? device}) async {
    if (isConnected.value) return;
    final d = device ?? await discoverFirstMatching();
    if (d == null) {
      // fallback: coba dari bonded
      final bonded = await bondedDevices();
      final alt = bonded.firstWhereOrNull(
        (b) =>
            (b.name ?? '').toUpperCase().contains(BtConstants.deviceNameHint),
      );
      if (alt == null) {
        throw Exception(
          'Device NEUROKIT tidak ditemukan. Pastikan pairing di Settings.',
        );
      }
      await _connectToAddress(alt.address);
      connectedDevice.value = alt;
      return;
    }
    await _connectToAddress(d.address);
    connectedDevice.value = d;
  }

  Future<void> _connectToAddress(String address) async {
    await disconnect();
    _conn = await BluetoothConnection.toAddress(address);
    isConnected.value = true;

    _conn!.input?.listen(
      (data) {
        final text = utf8.decode(data);
        for (final line in const LineSplitter().convert(text)) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty) _lineStream.add(trimmed);
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

    // minta status awal
    await sendLine('STATUS?');
  }

  Future<void> sendLine(String line) async {
    if (_conn == null) throw Exception('Belum terhubung');
    final payload = (line.endsWith('\n') ? line : '$line\n');
    _conn!.output.add(utf8.encode(payload));
    await _conn!.output.allSent;
  }

  Future<void> disconnect() async {
    try {
      await _scanSub?.cancel();
      _scanSub = null;
      await _conn?.close();
      _conn?.dispose();
      _conn = null;
    } catch (_) {}
    isConnected.value = false;
    connectedDevice.value = null;
  }

  @override
  void onClose() {
    _lineStream.close();
    super.onClose();
  }
}
