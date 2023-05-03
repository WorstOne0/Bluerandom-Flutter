// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
// Screens
import '/screens/splash_screen.dart';
// Styles
import 'styles/style_config.dart';

void main() async {
  // Flutter initialization
  WidgetsFlutterBinding.ensureInitialized();

  // *** RIVERPOD ***
  // State management with Riverpod (https://codewithandrea.com/articles/flutter-state-management-riverpod/)

  // Startup (https://codewithandrea.com/articles/riverpod-initialize-listener-app-startup/)
  // 1. Create a ProviderContainer
  final container = ProviderContainer(observers: [/*Logger()*/]);
  // 2. Use it to read the provider
  // This starts the firebase messaging listener
  // container.read(firebaseMessagingProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: false ? dark() : light(),
      duration: const Duration(milliseconds: 500),
      // GetX package - adds useful funcionalities
      builder: (_, theme) => MaterialApp(
        title: 'Bluerandom',
        theme: light(),
        // Start with the Splash Screen
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
