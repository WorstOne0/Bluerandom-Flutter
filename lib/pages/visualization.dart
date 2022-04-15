import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';
import 'package:bluerandom/models/extraction.dart';

import 'package:bluerandom/widgets/deviceList.dart';

class VisualizationPage extends StatelessWidget {
  const VisualizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instance of extraction class
    Extraction extraction = Extraction();

    return Scaffold(
        appBar: AppBar(title: Text("Find Devices"), centerTitle: true),
        // Cosumer let the app uses the bluetooth connection
        body: Consumer<BluetoothConnection>(builder: (context, value, child) {
          return StreamBuilder(
              // Listen to the state of the bluetooth
              stream: value.getConnection().statusStream,
              builder: (c, snapshot) {
                // Bluetooth is active and ready to use
                if (snapshot.data == BleStatus.ready) {
                  return StreamBuilder(
                      // Listen and start the scan
                      stream: value.getConnection().scanForDevices(
                          withServices: [], scanMode: ScanMode.lowLatency),
                      builder: (c, snapshot) {
                        // Scan only grab a device at time, and only when the rssi value change
                        if (snapshot.hasData) {
                          DiscoveredDevice? device =
                              snapshot.data as DiscoveredDevice?;

                          // Adds the device to the list
                          value.addDeviceToList(device);

                          // This is the right place???
                          extraction.startExtraction(value.getDevices(),
                              ExtractionMethod.oddOrEvenDifference);
                        }

                        return DeviceList();
                      });
                }

                // Bluetooth is turned off
                if (snapshot.data == BleStatus.poweredOff) {
                  return Container(
                    child: Text("Bluetooth Offline"),
                  );
                }

                // Doesn't have authorization
                if (snapshot.data == BleStatus.unauthorized) {
                  // value.requestPermissions();
                  return Container(
                    child: Text("Access Denied"),
                  );
                }

                // Platform does not support bluetooth
                if (snapshot.data == BleStatus.unsupported) {
                  return Container(
                    child: Text("Bluetooth não suportado"),
                  );
                }

                // Unknow
                return Container(
                  child: Text("Erro não conhecido"),
                );
              });
        }));
  }
}
