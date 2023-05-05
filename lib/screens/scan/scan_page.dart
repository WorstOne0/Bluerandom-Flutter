// Dart
import 'dart:async';
// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
// Controllers
import '/models/device_information.dart';
import '/controllers/bluetooth_controller.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // Lottie
  late final AnimationController _controller;

  StreamSubscription? _bluetoothConnection, _bluetoothStatus;

  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _bluetoothStatus = ref.read(bluetoothConnectionProvider).statusStream.listen((status) {
      if (status != BleStatus.ready) {
        stopScan();
      }

      if (status == BleStatus.ready) {
        startScan();
      }

      ref.read(bluetoothProvider.notifier).updateBluetoothStatus(status);
    });

    ref.read(bluetoothProvider.notifier).resetTimer();
  }

  void startScan() {
    _bluetoothConnection = ref.read(bluetoothConnectionProvider).scanForDevices(
      withServices: [],
      scanMode: ScanMode.balanced,
    ).listen((device) {
      // Add the device
      ref.read(bluetoothProvider.notifier).addDeviceToList(device);
    });

    setState(() {
      _isScanning = true;
    });
  }

  void stopScan() async {
    await _bluetoothConnection?.cancel();

    setState(() {
      _isScanning = false;
    });
  }

  @override
  void dispose() {
    _bluetoothConnection?.cancel();
    _bluetoothStatus?.cancel();

    // don't forget to close subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<DeviceInformation> deviceList = ref.watch(bluetoothProvider).deviceList.values.toList();
    BleStatus bluetoothStatus = ref.watch(bluetoothProvider).bluetoothStatus;

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: bluetoothStatus != BleStatus.ready
              ? const Text("Não Pronto")
              : Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  SizedBox(width: 15),
                                  Icon(Icons.bluetooth_searching),
                                  SizedBox(width: 10),
                                  Text(
                                    "Searching ",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isScanning,
                                onChanged: (value) {
                                  value ? startScan() : stopScan();
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          _isScanning
                              ? Lottie.asset(
                                  "assets/lottie/121006-bluetooth-searching.json",
                                  controller: _controller,
                                  onLoaded: (composition) {
                                    _controller
                                      ..duration = const Duration(seconds: 4)
                                      ..repeat();
                                  },
                                  height: 120,
                                )
                              : Container(
                                  height: 120,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.bluetooth_disabled,
                                    size: 60,
                                  ),
                                ),
                          const SizedBox(height: 10),
                          Text(
                            _isScanning ? "Searching for devices..." : "Scan is off",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.edgesensor_high),
                                SizedBox(width: 10),
                                Text(
                                  "Dispositivos",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${deviceList.length}",
                              style: const TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: deviceList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: Container(
                                height: 80,
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Text("${deviceList[index].rssiNew}"),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          deviceList[index].name.isNotEmpty
                                              ? deviceList[index].name
                                              : "Unknown",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          deviceList[index].id,
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        )
                                      ],
                                    )),
                                    Text("${deviceList[index].rssiOld ?? ''}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
