// Flutter Packages
import 'package:bluerandom/screens/scan/information_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Screens
import 'package:bluerandom/screens/scan/scan_page.dart';
// Controllers
import 'package:bluerandom/controllers/bluetooth_controller.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();

    asyncInit();
  }

  void asyncInit() async {
    _hasPermission = await ref.read(bluetoothProvider.notifier).requestPermissions();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_hasPermission
          ? Text("Loading")
          : PageView(
              controller: _pageController,
              onPageChanged: (value) => setState(() => _currentPage = value),
              children: const [ScanPage(), InformationPage()],
            ),
      bottomNavigationBar: _hasPermission
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.radar),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  label: 'Dados',
                )
              ],
              currentIndex: _currentPage,
              onTap: (value) {
                _pageController.animateToPage(
                  value,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            )
          : null,
    );
  }
}

// @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: GestureDetector(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 100),
//             child: Icon(
//               Icons.power_settings_new,
//               size: 70,
//               color: Colors.blue[500],
//             ),
//             height: 150,
//             width: 150,
//             decoration: BoxDecoration(
//                 color: Color(0xFF121212),
//                 border: Border.all(color: Colors.blue.shade500, width: 2),
//                 borderRadius: BorderRadius.circular(100),
//                 boxShadow: _buttonIsElevated
//                     ? [
//                         BoxShadow(
//                             color: Colors.blue.shade500,
//                             offset: const Offset(4, 4),
//                             blurRadius: 20,
//                             spreadRadius: 1),
//                         BoxShadow(
//                             color: Colors.blue.shade400,
//                             offset: const Offset(-4, -4),
//                             blurRadius: 20,
//                             spreadRadius: 1),
//                       ]
//                     : null),
//           ),
//           onTap: () {
//             setState(() {
//               _buttonIsElevated = true;

//               // Changes to the next page
//               Future.delayed(Duration(milliseconds: 1000), () {
//                 Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => VisualizationPage()));
//               });
//             });
//           },
//         ),
//         alignment: Alignment.center,
//         color: Color(0xFF121212),
//       ),
//     );
//   }