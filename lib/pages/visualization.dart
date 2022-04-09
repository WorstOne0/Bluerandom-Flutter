import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

import 'package:bluerandom/widgets/deviceList.dart';

class VisualizationPage extends StatelessWidget {
  const VisualizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Find Devices"), centerTitle: true),
        body: DeviceList());
  }
}
