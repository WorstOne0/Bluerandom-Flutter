import 'package:bluerandom/models/bluetoothConnection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

class VisualizationPage extends StatefulWidget {
  const VisualizationPage({Key? key}) : super(key: key);

  @override
  State<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: Container(
        child: Consumer<BluetoothConnection>(builder: (context, value, child) {
          return ListView.builder(
              itemCount: value.getDevices().length,
              itemBuilder: (context, index) {
                return Container(
                    height: 50,
                    child: Column(
                      children: [
                        Text(
                            value.getDevices()[index].name == ''
                                ? '(unknown device)'
                                : value.getDevices()[index].name,
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        Text(value.getDevices()[index].id.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 15))
                      ],
                    ));
              });
        }),
      ),
    ));
  }
}
