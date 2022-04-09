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
  // List with all RSSI values
  final List<int> _rssiValues = <int>[];
  // List with all the Bluetooth devices
  final List<BluetoothDevice> _devicesList = <BluetoothDevice>[];
  // Connected Device
  BluetoothDevice? _connectedDevice;
  // List of services of Connected Device
  List<BluetoothService> _services = <BluetoothService>[];
  //final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  // Return devices List
  List<BluetoothDevice> getDevices() => _devicesList;
  // Return RSSI
  int getRssi(int index) => _rssiValues[index];
  // Return device
  BluetoothDevice getDevice(int index) => _devicesList[index];
  // Return connected device
  BluetoothDevice? getConnectedDevice() => _connectedDevice;
  // Return services
  List<BluetoothService> getServices() => _services;

  // Adds to the device List
  void _addDeviceTolist(final BluetoothDevice device, final int rssi) {
    if (!_devicesList.contains(device)) {
      _devicesList.add(device);
      _rssiValues.add(rssi);
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
        _addDeviceTolist(result.device, result.rssi);
      }
    });
  }

  // Connects to a device
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
      _services = await device.discoverServices();
      _connectedDevice = device;

      notifyListeners();
    }
  }

  void disconnectDevice() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;

    scanDevices();

    notifyListeners();
  }

  void stopScan() => _flutterBlue.stopScan();
}
