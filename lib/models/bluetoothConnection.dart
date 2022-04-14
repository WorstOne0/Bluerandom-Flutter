import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';

class BluetoothConnection extends ChangeNotifier {
  BluetoothConnection() {
    requestPermissions();
  }

  // Permissions
  bool hasAccess = false;
  // Bluetooth Instance
  final FlutterReactiveBle _connection = FlutterReactiveBle();
  // List with all devices
  List<Map> _deviceList = <Map>[];

  List<DiscoveredDevice> list = <DiscoveredDevice>[];

  // Get connection
  FlutterReactiveBle getConnection() => _connection;
  // Get all devices
  List<Map> getDevices() => _deviceList;
  // Get device
  Map getDevice(index) => _deviceList[index];

  // Adds to the device List
  void addDeviceToList(final DiscoveredDevice? device) {
    bool insert = true;

    // Updates RSSI if already exists
    _deviceList.forEach((element) {
      if (element["id"] == device?.id) {
        element["rssi"] = device?.rssi;
        insert = false;
      }
    });

    // If doesn't existe, adds to the list
    if (insert) {
      _deviceList
          .add({"id": device?.id, "name": device?.name, "rssi": device?.rssi});
    }
  }

  // Start the scan
  void scanDevices() {
    _connection.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((device) {
      // Não funciona nao sei porque, se eu colocar apenas para mostrar os dispositivos funciona ok
      // mas se eu tentar adicionar na lista ele da erro e nao deixa
    }, onError: (Object error) {
      print(error);
    });
  }

  void requestPermissions() async {
    var permission = await LocationPermissions().requestPermissions();

    if (permission == PermissionStatus.granted) {
      hasAccess = true;
      notifyListeners();
    }
  }
}
