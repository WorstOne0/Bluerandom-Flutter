import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/unused.dart';

// Não funciona mais por que foi trocado de lib(flutter_blue)
class DeviceCaracteristcs extends StatelessWidget {
  const DeviceCaracteristcs({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Container(child: Consumer<BluetoothConnectionBlue>(
      builder: (context, value, child) {
        return Scaffold(
            appBar: AppBar(
                title: Text(device.name),
                centerTitle: true,
                actions: value.getConnectedDevice() == device
                    ? [
                        IconButton(
                            onPressed: () {
                              if (value.getConnectedDevice() == device) {
                                value.disconnectDevice();
                              }
                            },
                            icon: Icon(Icons.bluetooth_disabled))
                      ]
                    : []),
            body: Consumer<BluetoothConnectionBlue>(
                builder: (context, value, child) {
              return Container(
                  child: Container(
                      width: double.infinity,
                      child: value.getConnectedDevice() == device
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                      value.getServices()[0].uuid.toString()),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Icon(
                                    Icons.bluetooth_disabled,
                                    size: 170,
                                    color: Colors.grey[300],
                                  ),
                                  Text(
                                    "Disconnected",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 35,
                                    ),
                                  )
                                ])));
            }));
      },
    ));
  }
}
