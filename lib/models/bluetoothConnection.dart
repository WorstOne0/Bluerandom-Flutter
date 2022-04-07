import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue/gen/flutterblue.pbjson.dart';

class BluetoothConnection extends ChangeNotifier {
  BluetoothConnection() {
    scanDevices();
  }

  // Bluetooth Instance
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  // List with all the Bluetooth devices
  final List<BluetoothDevice> _devicesList = <BluetoothDevice>[];
  BluetoothDevice? _connectedDevice;
  //final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  // Return devices List
  List<BluetoothDevice> getDevices() => _devicesList;
  // Return device
  BluetoothDevice getDevice(int index) => _devicesList[index];
  // Return connected device
  BluetoothDevice? getConnectedDevice() => _connectedDevice;

  // Adds to the device List
  void _addDeviceTolist(final BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      _devicesList.add(device);
      notifyListeners();
    }
  }

  // Start the scan
  void scanDevices() {
    // Verify if there is a default timeout
    _flutterBlue.startScan();

    // Listen to scanResults Stream and adds to the List
    _flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    if (!_devicesList.contains(device)) {
      return;
    }

    int index = _devicesList.indexOf(device);

    stopScan();

    try {
      await device.connect();
    } catch (error) {
      if (error != "already_connected") {
        throw error;
      }
    } finally {
      List<BluetoothService> services = await device.discoverServices();
      _connectedDevice = device;

      notifyListeners();
    }
  }

  void disconnectDevice() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;

    notifyListeners();
  }

  void stopScan() => _flutterBlue.stopScan();
}
