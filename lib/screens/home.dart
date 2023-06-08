// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:wakelock/wakelock.dart';
// Screens
import '/screens/scan/scan_page.dart';
import '/screens/scan/information_page.dart';
import '/screens/settings_page.dart';
// Controllers
import '/controllers/bluetooth_controller.dart';

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

    // Keeps the screen on
    Wakelock.enable();

    asyncInit();
  }

  void asyncInit() async {
    _hasPermission = await ref.read(bluetoothProvider.notifier).requestPermissions();

    setState(() {});
  }

  @override
  void dispose() {
    Wakelock.disable();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        body: !_hasPermission
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      size: 60,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Sem permissão",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
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
                    label: 'Busca',
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
