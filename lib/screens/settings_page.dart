// Flutter Packages
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:bluerandom/services/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../styles/style_config.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Theme"),
                      ThemeSwitcher.withTheme(
                        builder: (p0, switcher, theme) => IconButton(
                            onPressed: () {
                              ref.read(secureStorageProvider).saveString(
                                    "dark_mode",
                                    (theme.brightness == Brightness.light).toString(),
                                  );

                              switcher.changeTheme(
                                theme: theme.brightness == Brightness.light ? dark() : light(),
                              );
                            },
                            icon: Row(
                              children: [
                                Text(
                                  theme.brightness == Brightness.light ? "Light Mode" : "Dark Mode",
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    theme.brightness == Brightness.light
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
