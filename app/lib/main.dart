import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'src/ads.dart';
import 'src/favorites.dart';
import 'src/home_screen.dart';
import 'src/models.dart';
import 'src/splash_screen.dart';
import 'src/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: AppColors.bg,
  ));
  // Start consent + ad loading during the splash, not after data finishes.
  unawaited(Ads.instance.init());
  runApp(const BootApp());
}

/// Launch flow: native splash -> Flutter logo splash (loads data) -> home.
class BootApp extends StatelessWidget {
  const BootApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cheat Codes for GTA',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: SplashScreen(
          load: () async {
            final favorites = Favorites();
            final r = await Future.wait([CheatData.load(), favorites.init()]);
            return (r[0] as CheatData, favorites);
          },
          builder: (o) {
            final (data, favorites) = o as (CheatData, Favorites);
            return HomeScreen(data: data, favorites: favorites);
          },
        ),
      );
}

class CheatApp extends StatelessWidget {
  const CheatApp({super.key, required this.data, required this.favorites});
  final CheatData data;
  final Favorites favorites;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cheat Codes for GTA',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: HomeScreen(data: data, favorites: favorites),
      );
}
