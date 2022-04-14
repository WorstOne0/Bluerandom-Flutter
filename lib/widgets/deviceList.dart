import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/pages/deviceCaracteristcs.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({Key? key}) : super(key: key);

  // On InitState
  // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     Bluetooth connection = ...
  //   });

  @override
  Widget build(BuildContext context) {
    int tryingConnection = -1;

    return Container(
        child: Consumer<BluetoothConnection>(builder: (context, value, child) {
      return ListView.builder(
        itemCount: value.getDevices().length,
        itemBuilder: (context, index) {
          return GestureDetector(
              child: Container(
                  height: 70,
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            child:
                                Text(value.getDevice(index)["rssi"].toString()),
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
                                  value.getDevice(index)["name"] == ""
                                      ? "Unknow Device"
                                      : value.getDevice(index)["name"],
                                  style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Text(value.getDevice(index)["id"].toString(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic))
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              onTap: () {
                // Future.delayed(Duration(milliseconds: 500), () {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => DeviceCaracteristcs(
                //                 device: value.getDevice(index),
                //               )));
              });
        },
      );
    }));
  }
}
