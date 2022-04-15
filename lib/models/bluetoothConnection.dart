import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';

import 'package:bluerandom/models/extraction.dart';

class BluetoothConnection extends ChangeNotifier {
  BluetoothConnection() {
    requestPermissions();
  }

  // Permissions
  bool hasAccess = false;
  // Bluetooth Instance
  final FlutterReactiveBle _connection = FlutterReactiveBle();
  // List with all devices - Map with id, name, rssiNew, rssiOld
  List<Map> _deviceList = <Map>[];
  // Instance of extraction class
  final Extraction _extraction = Extraction();

  // Get connection
  FlutterReactiveBle getConnection() => _connection;
  // Get all devices
  List<Map> getDevices() => _deviceList;
  // Get device
  Map getDevice(index) => _deviceList[index];

  // Get extraction connection
  Extraction getExtraction() => _extraction;
  // Get byte from Extraction
  List<int> getByteExtraction() => _extraction.getByte();
  // Get count from Extraction
  int getCountExtraction() => _extraction.getCount();

  // Adds to the device List
  void addDeviceToList(final DiscoveredDevice? device) {
    bool insert = true;

    // Updates RSSI if already exists
    _deviceList.forEach((element) {
      if (element["id"] == device?.id) {
        element["rssiOld"] = element["rssiNew"];
        element["rssiNew"] = device?.rssi;

        // Make the extraction for the device
        _extraction.startExtraction(element, ExtractionMethod.oddOrEven);

        // ****** If necessary ******
        // After determined time changes rssiOld to rssiNew
        // Because it only the scan only notifies when the rssi value changes
        // So the rssiNew and rssiOld wont ever be the same

        // Future.delayed(Duration(seconds: 5), () {
        //   print(element["id"]);
        //   element["rssiOld"] = element["rssiNew"];
        // });

        // Doesn't need to insert in the list
        insert = false;
      }
    });

    // If doesn't exist, adds to the list
    if (insert) {
      Map newDevice = {
        "id": device?.id,
        "name": device?.name,
        "rssiNew": device?.rssi,
        "rssiOld": 0
      };

      _deviceList.add(newDevice);

      // Make the extraction for the device
      _extraction.startExtraction(newDevice, ExtractionMethod.oddOrEven);
    }
  }

  // Start the scan **** NOT USED -  It was used a Stream Builder instead - just because it works
  void scanDevices() {
    _connection.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((device) {
      // Não funciona nao sei porque, se eu colocar apenas para mostrar os dispositivos funciona ok
      // mas se eu tentar adicionar na lista ele da erro e nao deixa
    }, onError: (Object error) {
      print(error);
    });
  }

  // Request the Permissions
  void requestPermissions() async {
    var permission = await LocationPermissions().requestPermissions();

    if (permission == PermissionStatus.granted) {
      hasAccess = true;
      notifyListeners();
    }
  }
}
