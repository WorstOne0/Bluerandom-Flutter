import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bluerandom/models/bluetoothConnection.dart';
import 'package:bluerandom/models/extraction.dart';

import 'package:bluerandom/pages/splashScreen.dart';
import 'package:bluerandom/pages/startPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the bluetooth class controler to the entire app
    return ChangeNotifierProvider(
      create: (context) => BluetoothConnection(),
      child: MaterialApp(
        title: 'Bluerandom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Start with the Splash Screen
        home: SplashScreen(goToPage: StartPage(), duration: 3),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
