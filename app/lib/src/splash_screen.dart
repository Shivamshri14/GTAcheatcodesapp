import 'package:material_ui/material_ui.dart';

import 'ads.dart';
import 'home_screen.dart' show AppLogo;
import 'theme.dart';

/// Flutter-side splash shown right after the native (Android 12+) splash,
/// while cheat data and favourites load.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.load, required this.builder});
  final Future<Object> Function() load;
  final Widget Function(Object loaded) builder;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final results = await Future.wait(
        [widget.load(), Future<void>.delayed(const Duration(milliseconds: 1300))]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, _, _) => widget.builder(results[0] as Object),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ));
    Ads.instance.onSplashComplete();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _c,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(scale),
                child: const AppLogo(size: 150)),
            const SizedBox(height: 26),
            const Text('CHEAT CODES FOR GTA',
                style: TextStyle(
                    fontFamily: 'Anton', fontSize: 24, letterSpacing: 1, color: Colors.white)),
            const SizedBox(height: 6),
            const Text('PlayStation · Xbox · PC',
                style: TextStyle(color: AppColors.text2, fontSize: 13)),
            const SizedBox(height: 28),
            const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.accent)),
          ]),
        ),
      ),
    );
  }
}
