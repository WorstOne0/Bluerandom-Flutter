// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
// Screens
import '/screens/splash_screen.dart';
// Services
import 'services/secure_storage.dart';
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

  // Dark Mode
  bool isDark = await container.read(secureStorageProvider).readString("dark_mode") == "true";

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(
        isDark: isDark,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({required this.isDark, Key? key}) : super(key: key);

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: isDark ? dark() : light(),
      duration: const Duration(milliseconds: 500),
      builder: (_, theme) => MaterialApp(
        title: 'Bluerandom',
        theme: theme,
        // Start with the Splash Screen
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
