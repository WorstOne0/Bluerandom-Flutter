import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

import 'package:bluerandom/widgets/deviceList.dart';
import 'package:bluerandom/widgets/deviceCaracteristcs.dart';

class VisualizationPage extends StatefulWidget {
  const VisualizationPage({Key? key}) : super(key: key);

  @override
  State<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage> {
  @override
  Widget build(BuildContext context) {
    BluetoothConnection connection = Provider.of<BluetoothConnection>(context);

    return Scaffold(
        appBar: AppBar(title: Text("Find Devices"), centerTitle: true),
        body: connection.getConnectedDevice() == null
            ? DeviceList()
            : DeviceCaracteristcs());
  }
}
