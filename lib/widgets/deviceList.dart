import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int tryingConnection = -1;

    return Container(
      child: Consumer<BluetoothConnection>(builder: (context, value, child) {
        return ListView.builder(
            itemCount: value.getDevices().length,
            itemBuilder: (context, index) {
              return Container(
                  height: 70,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("50"),
                          )),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  value.getDevice(index).name == ''
                                      ? 'Unknown evice'
                                      : value.getDevice(index).name,
                                  style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Text(value.getDevice(index).id.toString(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                            child: ElevatedButton(
                          child: Text(tryingConnection == index
                              ? "Loading"
                              : "Connect"),
                          onPressed: () async {
                            BluetoothConnection connection =
                                Provider.of<BluetoothConnection>(context,
                                    listen: false);

                            tryingConnection = index;
                            connection.connectToDevice(value.getDevice(index));
                          },
                        )),
                      )
                    ],
                  ));
            });
      }),
    );
  }
}
