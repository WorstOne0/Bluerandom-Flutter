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
              ? Text("Não Pronto")
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
                                children: [
                                  SizedBox(width: 15),
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
                          SizedBox(height: 5),
                          _isScanning
                              ? Lottie.network(
                                  "https://assets10.lottiefiles.com/packages/lf20_JMvjhFMmBd.json",
                                  controller: _controller,
                                  onLoaded: (composition) {
                                    _controller
                                      ..duration = const Duration(seconds: 4)
                                      ..repeat();
                                  },
                                  height: 150,
                                )
                              : Container(
                                  height: 150,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.bluetooth_disabled,
                                    size: 60,
                                  ),
                                ),
                          SizedBox(height: 10),
                          Text(
                            _isScanning ? "Searching for devices..." : "Scan is off",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dispositivos",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${deviceList.length}",
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: deviceList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2,
                              child: Container(
                                height: 80,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Text("${deviceList[index].rssiNew}"),
                                    Expanded(
                                        child: Text(
                                      deviceList[index].name.isNotEmpty
                                          ? deviceList[index].name
                                          : "Unknown",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
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
