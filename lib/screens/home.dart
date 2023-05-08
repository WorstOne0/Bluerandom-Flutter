// Flutter Packages
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:bluerandom/screens/scan/information_page.dart';
import 'package:bluerandom/screens/settings_page.dart';
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
    return ThemeSwitchingArea(
      child: Scaffold(
        body: !_hasPermission
            ? const Text("Loading")
            : PageView(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                children: const [ScanPage(), InformationPage(), SettingsPage()],
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
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Config',
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
      ),
    );
  }
}
