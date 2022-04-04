import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothConnection extends ChangeNotifier {
  BluetoothConnection() {
    scanDevices();
  }

  // Instancia do Bluetooth
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  // Lista com todos os Dispositvos Bluetooth
  final List<BluetoothDevice> _devicesList = <BluetoothDevice>[];
  //final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  List<BluetoothDevice> getDevices() => _devicesList;

  void _addDeviceTolist(final BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      _devicesList.add(device);
      notifyListeners();
    }
  }

  void scanDevices() {
    // Scanning
    _flutterBlue.startScan(timeout: Duration(seconds: 30));

    // _flutterBlue.connectedDevices
    //     .asStream()
    //     .listen((List<BluetoothDevice> devices) {
    //   for (BluetoothDevice device in devices) {
    //     _addDeviceTolist(device);
    //   }
    // });

    // Adiciona os dispositivos na lista
    _flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
  }
}
