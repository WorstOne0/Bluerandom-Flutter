// Flutter Packages
import 'package:bluerandom/controllers/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> with SingleTickerProviderStateMixin {
  //
  late final AnimationController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    asyncInit();
  }

  void asyncInit() async {
    ref.read(bluetoothProvider.notifier).generateReport();

    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.read(bluetoothProvider.notifier).generateReport();

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Lottie.asset(
                  "assets/lottie/report_blue.json",
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = const Duration(seconds: 2)
                      ..repeat();
                  },
                  height: 250,
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Ainda não Feito!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 0,
                      color: Colors.transparent,
                      child: const Text(
                        "Voltar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
