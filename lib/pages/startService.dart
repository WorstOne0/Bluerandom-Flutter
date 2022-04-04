import 'package:bluerandom/pages/teste.dart';
import 'package:bluerandom/widgets/visualization.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool _buttonIsElevated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: GestureDetector(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              child: Icon(
                Icons.power_settings_new,
                size: 70,
                color: Colors.blue[500],
              ),
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  color: Color(0xFF121212),
                  border: Border.all(color: Colors.blue.shade500, width: 2),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: _buttonIsElevated
                      ? [
                          BoxShadow(
                              color: Colors.blue.shade500,
                              offset: const Offset(4, 4),
                              blurRadius: 20,
                              spreadRadius: 1),
                          BoxShadow(
                              color: Colors.blue.shade400,
                              offset: const Offset(-4, -4),
                              blurRadius: 20,
                              spreadRadius: 1),
                        ]
                      : null),
            ),
            onTap: () {
              setState(() {
                _buttonIsElevated = true;
                Future.delayed(Duration(milliseconds: 1500), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VisualizationPage()));
                });
              });
            },
          ),
          alignment: Alignment.center,
          color: Color(0xFF121212),
        ),
      ),
    );
  }
}
