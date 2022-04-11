import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:bluerandom/models/bluetoothConnectionR.dart';

import 'package:bluerandom/widgets/deviceList.dart';

class VisualizationPage extends StatelessWidget {
  const VisualizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Find Devices"), centerTitle: true),
        body: Consumer<BluetoothConnectionR>(builder: (context, value, child) {
          if (value.hasAccess) {
            return StreamBuilder(
                stream: value.getConnection().scanForDevices(
                    withServices: [], scanMode: ScanMode.balanced),
                builder: (c, snapshot) {
                  if (snapshot.hasData) {
                    DiscoveredDevice? device =
                        snapshot.data as DiscoveredDevice?;
                    value.addDeviceToList(device);
                  }

                  return DeviceList();
                });
          }

          // value.requestPermissions();
          return Container(
            child: Text("Access Denied"),
          );
        }));
  }
}
