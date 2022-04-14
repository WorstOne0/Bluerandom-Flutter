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
    Extraction extraction = Extraction();

    return Scaffold(
        appBar: AppBar(title: Text("Find Devices"), centerTitle: true),
        body: Consumer<BluetoothConnection>(builder: (context, value, child) {
          return StreamBuilder(
              stream: value.getConnection().statusStream,
              builder: (c, snapshot) {
                if (snapshot.data == BleStatus.ready) {
                  return StreamBuilder(
                      stream: value.getConnection().scanForDevices(
                          withServices: [], scanMode: ScanMode.lowLatency),
                      builder: (c, snapshot) {
                        if (snapshot.hasData) {
                          DiscoveredDevice? device =
                              snapshot.data as DiscoveredDevice?;
                          print(device);
                          value.addDeviceToList(device);
                        }

                        // This is the right place???
                        extraction.startExtraction(
                            value.getDevices(), ExtractionMethod.oddOrEven);

                        return DeviceList();
                      });
                }

                if (snapshot.data == BleStatus.poweredOff) {
                  return Container(
                    child: Text("Bluetooth Offline"),
                  );
                }

                if (snapshot.data == BleStatus.unauthorized) {
                  // value.requestPermissions();
                  return Container(
                    child: Text("Access Denied"),
                  );
                }

                if (snapshot.data == BleStatus.unsupported) {
                  return Container(
                    child: Text("Bluetooth não suportado"),
                  );
                }

                return Container(
                  child: Text("Erro não conhecido"),
                );
              });
        }));
  }
}
