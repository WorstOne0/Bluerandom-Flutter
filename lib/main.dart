import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/pages/splashScreen.dart';
import 'package:bluerandom/pages/startPage.dart';
import 'package:bluerandom/pages/visualization.dart';
import 'package:bluerandom/pages/deviceCaracteristcs.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BluetoothConnection(),
      child: MaterialApp(
        title: 'Bluerandom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(goToPage: StartPage(), duration: 3),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
