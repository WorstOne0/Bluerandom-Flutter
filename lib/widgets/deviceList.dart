import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({Key? key}) : super(key: key);

  // On InitState
  // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     Bluetooth connection = ...
  //   });

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Consumer<BluetoothConnection>(builder: (context, value, child) {
      return Container(
        child: Column(
          children: [
            Container(
              height: 50,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ultimo Bit Gerado => "),
                    Text(value.getExtraction().lastByte.toString())
                  ]),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(value.getExtraction().totalBytes.toString()),
                      alignment: Alignment.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Text(value.getByteExtraction().toString()),
                      alignment: Alignment.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(value.getCountExtraction().toString()),
                      alignment: Alignment.center,
                    ),
                  )
                ],
              ),
              height: 70,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: value.getDevices().length,
              itemBuilder: (context, index) {
                return Container(
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
                                child: Text(value
                                    .getDevice(index)["rssiNew"]
                                    .toString()),
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
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(value
                                    .getDevice(index)["rssiOld"]
                                    .toString()),
                              )),
                        ],
                      )),
                );
              },
            ),
          ],
        ),
      );
    }));
  }
}
