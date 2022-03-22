import 'package:bluerandom/widgets/bluetoothConnection.dart';
import 'package:flutter/material.dart';
import 'package:bluerandom/pages/splashScreen.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluerandom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(
        goToPage: BluetoothConnection(),
        duration: 3,
      ),
    );
  }
}

class TemporaryPage extends StatelessWidget {
  const TemporaryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Pagina Inicial"),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
    );
  }
}
