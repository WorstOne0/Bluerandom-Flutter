import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

class DeviceCaracteristcs extends StatelessWidget {
  const DeviceCaracteristcs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Consumer<BluetoothConnection>(
      builder: (context, value, child) {
        return Scaffold(
          body: Container(
              child: Text(value.getConnectedDevice()?.name ?? "Unknow")),
        );
      },
    ));
  }
}
