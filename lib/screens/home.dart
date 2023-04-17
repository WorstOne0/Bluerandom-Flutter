// Flutter Packages
import 'package:flutter/material.dart';
// Screens
import 'package:bluerandom/screens/visualization.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) => setState(() => _currentPage = value),
        children: [
          VisualizationPage(),
          Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
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