import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key, required this.goToPage, required this.duration})
      : super(key: key);

  final int duration;
  final Widget goToPage;

  @override
  Widget build(BuildContext context) {
    // Para setar o tempo da Duração da Splash Screen
    Future.delayed(Duration(seconds: duration), () {
      // Navigator.pushReplacement troca a tela atual(Splash Screen) por
      // outra tela sem que o usúario possa volta para a tela anterior
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => goToPage));
    });

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            // Fazer um Icone de Bluetooth
            Icon(Icons.bluetooth, color: Colors.white, size: 100),
            Container(
              child: Text(
                "Bluerandom",
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              margin: EdgeInsets.only(top: 20),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        width: double.infinity,
        color: Colors.blue[700],
      ),
    );
  }
}
