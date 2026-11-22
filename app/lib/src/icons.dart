import 'package:material_ui/material_ui.dart';

import 'models.dart';

/// Brand glyphs from Font Awesome Free (icons CC BY 4.0, font SIL OFL 1.1),
/// bundled as a 3-glyph subset in assets/fonts/fa-brands-subset.ttf.
class FaBrands {
  static const _f = 'FABrands';
  static const playstation = IconData(0xf3df, fontFamily: _f);
  static const xbox = IconData(0xf412, fontFamily: _f);
  static const windows = IconData(0xf17a, fontFamily: _f);
}

/// PlayStation / Xbox logos, and a monitor with a Windows logo for PC.
class PlatformIcon extends StatelessWidget {
  const PlatformIcon(this.platform, {super.key, this.size = 18, this.color});
  final Platform platform;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.white;
    return switch (platform) {
      Platform.ps => Icon(FaBrands.playstation, size: size * 1.05, color: c),
      Platform.xbox => Icon(FaBrands.xbox, size: size * 0.95, color: c),
      Platform.pc => SizedBox(
          width: size * 1.15,
          height: size,
          child: CustomPaint(painter: _MonitorPainter(c)),
        ),
    };
  }
}

class _MonitorPainter extends CustomPainter {
  _MonitorPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.09
      ..strokeJoin = StrokeJoin.round;
    final screen = RRect.fromLTRBR(w * 0.05, h * 0.05, w * 0.95, h * 0.70, Radius.circular(h * 0.08));
    canvas.drawRRect(screen, stroke);
    final fill = Paint()..color = color;
    // stand
    canvas.drawRect(Rect.fromLTRB(w * 0.44, h * 0.70, w * 0.56, h * 0.86), fill);
    canvas.drawRRect(
        RRect.fromLTRBR(w * 0.28, h * 0.84, w * 0.72, h * 0.95, Radius.circular(h * 0.05)), fill);
    // four-pane window logo on the screen
    final cx = w * 0.5, cy = h * 0.375, p = h * 0.13, g = h * 0.025;
    for (final dx in [-1, 1]) {
      for (final dy in [-1, 1]) {
        final l = dx < 0 ? cx - p - g / 2 : cx + g / 2;
        final t = dy < 0 ? cy - p - g / 2 : cy + g / 2;
        canvas.drawRect(Rect.fromLTWH(l, t, p, p), fill);
      }
    }
  }

  @override
  bool shouldRepaint(_MonitorPainter old) => old.color != color;
}
