// Dart
import 'dart:async';
// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
// Models
import '/models/device_information.dart';
import '/models/output_information.dart';
// Services
import '/services/secure_storage.dart';

enum ExtractionMethod { oddOrEvenDifference, earlyVonNeumann, oddOrEven }

class ChartData {
  late DateTime day;
  late double value;

  ChartData(this.day, this.value);
}

// My Controller are a mix between the Controller and Repository from the
// Riverpod Architecture (https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/).
// It handles the management of the widget state. (Riverpod Controller's job)
// It handles the data parsing and serialilzation from api's. (Riverpod Repository's job).

@immutable
class BluetoothState {
  const BluetoothState({
    required this.deviceList,
    required this.outputList,
    required this.bluetoothStatus,
    required this.outputByte,
    required this.lastByte,
    required this.totalThroughput,
  });

  final Map<String, DeviceInformation> deviceList;
  final List<OutputInformation> outputList;
  final BleStatus bluetoothStatus;
  //
  final List<int> outputByte;
  final List<int> lastByte;
  final double totalThroughput;

  BluetoothState copyWith({
    Map<String, DeviceInformation>? deviceList,
    List<OutputInformation>? outputList,
    BleStatus? bluetoothStatus,
    List<int>? outputByte,
    List<int>? lastByte,
    double? totalThroughput,
  }) {
    return BluetoothState(
      deviceList: deviceList ?? this.deviceList,
      outputList: outputList ?? this.outputList,
      bluetoothStatus: bluetoothStatus ?? this.bluetoothStatus,
      outputByte: outputByte ?? this.outputByte,
      lastByte: lastByte ?? this.lastByte,
      totalThroughput: totalThroughput ?? this.totalThroughput,
    );
  }
}

class BluetoothController extends StateNotifier<BluetoothState> {
  BluetoothController({required this.ref, required this.bluetoothConnectionProvider})
      : super(const BluetoothState(
          deviceList: {},
          outputList: [],
          bluetoothStatus: BleStatus.unknown,
          outputByte: [],
          lastByte: [],
          totalThroughput: 0,
        ));

  Ref ref;
  // Bluetooth Connection
  FlutterReactiveBle bluetoothConnectionProvider;
  // Persist Data
  SecureStorage storage = SecureStorage();

  Timer? timerReset, timerThroughput;

  // Number total of bytes generated
  double localThroughput = 0, maxThroughput = 0;
  int totalBits = 0, oldBits = 0;
  List<ChartData> chartData = [];
  DateTime? timeStartedExtract;
  // The number of bits generated, when have 8 bits(1 byte) it resets
  int _count = 0;

  // Request the Permissions
  Future<bool> requestPermissions() async {
    var permission = await LocationPermissions().requestPermissions();

    if (permission == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  void startedExtract() {
    localThroughput = 0;
    totalBits = 0;
    chartData.clear();
    timeStartedExtract = DateTime.now();

    _count = 0;

    timerThroughput = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeStartedExtract == null) return;

      localThroughput = (totalBits - oldBits) / 8;

      if (localThroughput > maxThroughput) {
        maxThroughput = localThroughput;
      }

      chartData.add(ChartData(DateTime.now(), localThroughput));
      if (chartData.length > 10) {
        chartData.removeAt(0);
      }

      Duration difference = DateTime.now().difference(timeStartedExtract!);
      double totalThroughput = totalBits / (difference.inSeconds * 8);

      oldBits = totalBits;
      state = state.copyWith(totalThroughput: totalThroughput);
    });
  }

  void stopExtract() {
    timerThroughput?.cancel();
  }

  void updateBluetoothStatus(BleStatus newStatus) {
    state = state.copyWith(bluetoothStatus: newStatus);
  }

  // Adds to the device List
  void addDeviceToList(DiscoveredDevice device) {
    Map<String, DeviceInformation> deviceList = {...state.deviceList};

    // Put trip in the map
    if (deviceList.containsKey(device.id)) {
      DeviceInformation? oldDevice = deviceList[device.id];
      DeviceInformation? newDevice =
          DeviceInformation(device.id, device.name, device.rssi, oldDevice?.rssiNew);

      deviceList.update(device.id, (value) => newDevice);

      startExtraction(newDevice, ExtractionMethod.oddOrEven);
    } else {
      DeviceInformation? newDevice = DeviceInformation(device.id, device.name, device.rssi, null);

      deviceList.addAll({device.id: newDevice});

      startExtraction(newDevice, ExtractionMethod.oddOrEven);
    }

    state = state.copyWith(deviceList: deviceList);
  }

  // Clear the list every 30 seconds because i dont know if a device is already out of range
  void resetTimer() {
    timerReset = Timer.periodic(Duration(seconds: 30), (timer) {
      state = state.copyWith(deviceList: {});
    });
  }

  // Exctration

  // Recieves a list of devices and extract the bits from it
  void startExtraction(DeviceInformation device, ExtractionMethod extractionMethod) {
    // Extract 1 bit from the RSSI
    int bit = extractBitFromRssi(
      device.rssiNew,
      device.rssiOld ?? 0,
      extractionMethod,
    );

    // If its not a invalid bit
    if (bit != -1) {
      List<int> _outputByte = [...state.outputByte], _lastByte = [...state.lastByte];

      _outputByte.add(bit);
      _count++;
      totalBits++;

      // Byte output
      if (_count == 8) {
        // Clear Count
        _count = 0;

        _lastByte = [..._outputByte];

        // Just clear the list for now
        _outputByte.clear();
      }

      state = state.copyWith(outputByte: _outputByte, lastByte: _lastByte);
    }
  }

  // Decides witch extractor use
  int extractBitFromRssi(int rssiNew, int rssiOld, ExtractionMethod extractionMethod) {
    // Selects the extraction method
    switch (extractionMethod) {
      case ExtractionMethod.oddOrEvenDifference:
        return oddOrEvenDifference(rssiNew, rssiOld);
      case ExtractionMethod.earlyVonNeumann:
        return earlyVonNeumann(rssiNew, rssiOld);
      case ExtractionMethod.oddOrEven:
        return oddOrEven(rssiNew);
    }
  }

  // Odd or Even Difference
  int oddOrEvenDifference(int rssiNew, int rssiOld) {
    int diference = rssiNew - rssiOld;

    if (diference != 0) {
      return diference % 2 == 0 ? 0 : 1;
    }

    return -1;
  }

  // "Early" Von neumann (last bit of two consecutive RSSI readings)
  int earlyVonNeumann(int rssiNew, int rssiOld) {
    int desloc1 = rssiNew & 0x1, desloc2 = rssiOld & 0x1;

    if (desloc1 == desloc2) {
      return -1;
    }

    return desloc2 == 0 ? 0 : 1;
  }

  // Just odd or even. For each rssi reading.
  int oddOrEven(int rssiNew) {
    return rssiNew % 2 == 0 ? 0 : 1;
  }
}

final bluetoothConnectionProvider = Provider<FlutterReactiveBle>((ref) => FlutterReactiveBle());

final bluetoothProvider = StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  return BluetoothController(
    ref: ref,
    bluetoothConnectionProvider: ref.watch(bluetoothConnectionProvider),
  );
});
