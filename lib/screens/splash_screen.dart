// Flutter Packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Screens
import 'package:bluerandom/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // After durations times change page
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.blue[700],
            image: const DecorationImage(
              image: AssetImage("assets/images/connections.jpg"),
              fit: BoxFit.cover,
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth, color: Colors.white, size: 100),
            const SizedBox(height: 15),
            Text(
              "Bluerandom",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontFamily: GoogleFonts.graduate().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
