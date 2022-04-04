import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Teste extends StatefulWidget {
  Teste({Key? key}) : super(key: key);

  // Instancia do Bluetooth
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  // Lista com todos os Dispositvos Bluetooth
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  //final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  // late BluetoothDevice _connectedDevice;
  // late List<BluetoothService> _services;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Scanning
    widget.flutterBlue.startScan(timeout: Duration(seconds: 30));

    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });

    // Adiciona os dispositivos na lista
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: ListView.builder(
              itemCount: widget.devicesList.length,
              itemBuilder: (context, index) {
                return Container(
                    height: 50,
                    child: Column(
                      children: [
                        Text(
                            widget.devicesList[index].name == ''
                                ? '(unknown device)'
                                : widget.devicesList[index].name,
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        Text(widget.devicesList[index].id.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 15))
                      ],
                    ));
              })),
    );
  }
}
