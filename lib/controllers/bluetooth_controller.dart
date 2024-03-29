// Dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
  // Battery
  Battery battery = Battery();
  // Timers
  Timer? timerReset, timerThroughput;

  // Extraction
  bool isExtracting = false, isOnReport = false;
  DateTime? timeStartedExtract, timeFinishedExtract;
  ExtractionMethod method = ExtractionMethod.oddOrEven;
  ScanMode scanMode = ScanMode.balanced;

  // Battery
  int batteryStart = 0, batteryEnd = 0;

  // Throughput
  double localThroughput = 0, maxThroughput = 0, maxDevices = 0;
  // Bits
  int totalBits = 0, oldBits = 0;
  // Real Time Data
  List<ChartData> realTimeThroughput = [];
  // Total Data
  List<ChartData> allThroughput = [], allDevices = [];
  // The number of bits generated, when have 8 bits (1 byte) it resets
  int count = 0;

  // Analise the data
  int buildingByte = 0, countByte = 7;
  final bytesBuilder = BytesBuilder();
  late Uint8List finalByteList;
  // Vars
  double shannonEntropy = 0, minEntropy = 0;

  // Request the Permissions
  Future<bool> requestPermissions() async {
    bool location, bluetooth;

    // Location
    location = await Permission.locationWhenInUse.request().isGranted;
    // Bluetooth
    bluetooth = await Permission.bluetoothScan.request().isGranted;

    return location && bluetooth;
  }

  void startedExtract() async {
    isExtracting = true;

    localThroughput = 0;
    maxThroughput = 0;
    totalBits = 0;
    realTimeThroughput.clear();
    allThroughput.clear();
    allDevices.clear();
    timeStartedExtract = DateTime.now();
    timeFinishedExtract = null;
    bytesBuilder.clear();
    shannonEntropy = 0;
    minEntropy = 0;

    count = 0;
    maxDevices = 0;
    countByte = 7;

    // Every second
    timerThroughput = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeStartedExtract == null) return;

      // How many bits were generated in the last second.
      localThroughput = (totalBits - oldBits) / 8;

      // To properly show the graph
      if (localThroughput > maxThroughput) {
        maxThroughput = localThroughput;
      }

      // Add to the real time Graph
      realTimeThroughput.add(ChartData(DateTime.now(), localThroughput));
      if (realTimeThroughput.length > 10) {
        realTimeThroughput.removeAt(0);
      }
      // Add to the total
      allThroughput.add(ChartData(DateTime.now(), localThroughput));

      double numDevices = state.deviceList.length.toDouble();
      // Add to the total
      allDevices.add(ChartData(
        DateTime.now(),
        numDevices != 0
            ? numDevices
            : allDevices.last.value == 0
                ? 0
                : allDevices.last.value,
      ));
      // To properly show the graph
      if (numDevices > maxDevices) {
        maxDevices = numDevices;
      }

      Duration difference = DateTime.now().difference(timeStartedExtract!);
      double totalThroughput = totalBits / (difference.inSeconds * 8);

      oldBits = totalBits;
      state = state.copyWith(totalThroughput: totalThroughput);
    });

    // Get Battery
    batteryStart = await battery.batteryLevel;
  }

  void stopExtract() async {
    isExtracting = false;
    timerThroughput?.cancel();

    timeFinishedExtract = DateTime.now();

    batteryEnd = await battery.batteryLevel;
  }

  void updateBluetoothStatus(BleStatus newStatus) {
    state = state.copyWith(bluetoothStatus: newStatus);
  }

  void changeMethod(ExtractionMethod newMethod) {
    method = newMethod;
  }

  void changeMode(ScanMode mode) {
    scanMode = mode;
  }

  // Adds to the device List
  void addDeviceToList(DiscoveredDevice device) {
    if (isOnReport) return;

    Map<String, DeviceInformation> deviceList = {...state.deviceList};

    // Put trip in the map
    if (deviceList.containsKey(device.id)) {
      DeviceInformation? oldDevice = deviceList[device.id];
      DeviceInformation? newDevice =
          DeviceInformation(device.id, device.name, device.rssi, oldDevice?.rssiNew);

      deviceList.update(device.id, (value) => newDevice);

      if (isExtracting) startExtraction(newDevice, method);
    } else {
      DeviceInformation? newDevice = DeviceInformation(device.id, device.name, device.rssi, null);

      deviceList.addAll({device.id: newDevice});

      if (isExtracting) startExtraction(newDevice, method);
    }

    state = state.copyWith(deviceList: deviceList);
  }

  // Clear the list every 30 seconds because i dont know if a device is already out of range
  void resetTimer() {
    timerReset = Timer.periodic(const Duration(seconds: 30), (timer) {
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
      // Stat
      buildingByte = buildingByte + (bit << countByte);
      countByte--;

      // Show
      List<int> _outputByte = [...state.outputByte], _lastByte = [...state.lastByte];

      _outputByte.add(bit);
      count++;
      totalBits++;

      // Byte output
      if (count == 8) {
        // Clear Count
        count = 0;
        countByte = 7;

        // print(_outputByte);
        // print("$buildingByte - ${buildingByte.toRadixString(2).padLeft(8, '0')}");
        bytesBuilder.addByte(buildingByte);

        _lastByte = [..._outputByte];

        _outputByte.clear();
        buildingByte = 0;
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

  // Report

  void generateReport() {
    isOnReport = true;

    finalByteList = bytesBuilder.toBytes();

    //
    shannonEntropy = calcShannonEntropy();
    //
    minEntropy = calcMinEntropy();
  }

  double calcShannonEntropy() {
    double entropy = 0;
    Map<String, double> frequencies = {};

    // Sum all the same values
    for (var element in finalByteList) {
      if (frequencies.containsKey(element.toString())) {
        frequencies.update(element.toString(), (value) => ++value);
      } else {
        frequencies.addAll({element.toString(): 1});
      }
    }

    // Divide by the Total to have the probability to appear
    frequencies = frequencies.map((key, value) => MapEntry(key, value / finalByteList.length));

    // Apply the formula Pi * log2(Pi)
    for (var element in frequencies.values) {
      entropy += (element * logBase(element, 2));
    }

    return -entropy;
  }

  double calcMinEntropy() {
    double maxFreq = 0;
    Map<String, double> frequencies = {};

    // Sum all the same values
    for (var element in finalByteList) {
      if (frequencies.containsKey(element.toString())) {
        frequencies.update(element.toString(), (value) => ++value);
      } else {
        frequencies.addAll({element.toString(): 1});
      }
    }

    // Apply the formula Pi * log2(Pi)
    for (var element in frequencies.values) {
      maxFreq = max(maxFreq, element);
    }

    return -(logBase((maxFreq / finalByteList.length), 2));
  }

  void leaveReport() {
    isOnReport = false;
  }

  double logBase(num x, num base) => log(x) / log(base);
}

final bluetoothConnectionProvider = Provider<FlutterReactiveBle>((ref) => FlutterReactiveBle());

final bluetoothProvider = StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  return BluetoothController(
    ref: ref,
    bluetoothConnectionProvider: ref.watch(bluetoothConnectionProvider),
  );
});
