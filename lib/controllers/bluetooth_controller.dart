// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
// Models
import '/models/extraction.dart';
// Services
import '/services/secure_storage.dart';

// My Controller are a mix between the Controller and Repository from the
// Riverpod Architecture (https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/).
// It handles the management of the widget state. (Riverpod Controller's job)
// It handles the data parsing and serialilzation from api's. (Riverpod Repository's job).

@immutable
class BluetoothState {
  const BluetoothState({
    required this.deviceList,
  });

  final List<Map> deviceList;

  BluetoothState copyWith({List<Map>? deviceList}) {
    return BluetoothState(
      deviceList: deviceList ?? this.deviceList,
    );
  }
}

class BluetoothController extends StateNotifier<BluetoothState> {
  BluetoothController({required this.ref})
      : super(const BluetoothState(deviceList: []));

  Ref ref;
  // Persist Data
  SecureStorage storage = SecureStorage();

  // Bluetooth Instance
  final FlutterReactiveBle _connection = FlutterReactiveBle();
  // Instance of extraction class
  final Extraction _extraction = Extraction();

  // Get connection
  FlutterReactiveBle getConnection() => _connection;
  // Get all devices
  List<Map> getDevices() => state.deviceList;
  // Get device
  Map getDevice(index) => state.deviceList[index];

  // Get extraction connection
  Extraction getExtraction() => _extraction;
  // Get byte from Extraction
  List<int> getByteExtraction() => _extraction.getByte();
  // Get count from Extraction
  int getCountExtraction() => _extraction.getCount();

  // Start the scan **** NOT USED -  It was used a Stream Builder instead - just because it works
  void scanDevices() {
    _connection.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((device) {
      // Não funciona nao sei porque, se eu colocar apenas para mostrar os dispositivos funciona ok
      // mas se eu tentar adicionar na lista ele da erro e nao deixa
    }, onError: (Object error) {});
  }

  // Adds to the device List
  void addDeviceToList(final DiscoveredDevice? device) {
    bool isNew = true;

    // Updates RSSI if already exists
    state.deviceList.forEach((element) {
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

        // Doesn't need to isNew in the list
        isNew = false;
      }
    });

    // If doesn't exist, adds to the list
    if (isNew) {
      Map newDevice = {
        "id": device?.id,
        "name": device?.name,
        "rssiNew": device?.rssi,
        "rssiOld": 0
      };

      state = state.copyWith(deviceList: state.deviceList..add(newDevice));

      // Make the extraction for the device
      _extraction.startExtraction(newDevice, ExtractionMethod.oddOrEven);
    }
  }

  // Request the Permissions
  Future<bool> requestPermissions() async {
    var permission = await LocationPermissions().requestPermissions();

    if (permission == PermissionStatus.granted) {
      return true;
    }

    return false;
  }
}

final bluetoothProvider =
    StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  return BluetoothController(ref: ref);
});
