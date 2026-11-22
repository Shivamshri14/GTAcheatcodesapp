import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'favorites.dart';
import 'models.dart';
import 'theme.dart';

/// One controller button rendered as a small coloured key cap.
/// PlayStation shapes and D-pad arrows are drawn, so they never depend on device fonts.
class ButtonCap extends StatelessWidget {
  const ButtonCap(this.token, {super.key, required this.platform});
  final String token;
  final Platform platform;

  static const _arrows = {
    'Up': Icons.arrow_upward_rounded,
    'Down': Icons.arrow_downward_rounded,
    'Left': Icons.arrow_back_rounded,
    'Right': Icons.arrow_forward_rounded,
  };
  static const _psColors = {
    'Cross': Color(0xFF7FA8FF),
    'Circle': Color(0xFFFF6B6B),
    'Square': Color(0xFFFF8AD8),
    'Triangle': Color(0xFF4FE3B0),
  };
  static const _xbColors = {
    'A': Color(0xFF6BD66B),
    'B': Color(0xFFFF6B6B),
    'X': Color(0xFF6BA8FF),
    'Y': Color(0xFFFFD54F),
  };

  @override
  Widget build(BuildContext context) {
    Widget child;
    Color border;
    bool round = true;
    if (_arrows.containsKey(token)) {
      border = Colors.white;
      child = Icon(_arrows[token], size: 17, color: Colors.white);
    } else if (platform == Platform.ps && _psColors.containsKey(token)) {
      border = _psColors[token]!;
      child = CustomPaint(size: const Size(14, 14), painter: _ShapePainter(token, border));
    } else {
      border = _xbColors[token] ?? const Color(0xFFE2DCEC);
      round = token.length == 1;
      child = Text(token,
          style: TextStyle(color: border, fontWeight: FontWeight.w700, fontSize: round ? 15 : 13));
    }
    return Semantics(
      label: token,
      child: Container(
        constraints: const BoxConstraints(minWidth: 30),
        height: 30,
        padding: EdgeInsets.symmetric(horizontal: round ? 6 : 8),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(round ? 15 : 8),
          border: Border.all(color: border.withValues(alpha: 0.55)),
        ),
        child: Align(widthFactor: 1, child: child),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.shape, this.color);
  final String shape;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width, h = size.height;
    switch (shape) {
      case 'Cross':
        canvas.drawLine(const Offset(1.5, 1.5), Offset(w - 1.5, h - 1.5), p);
        canvas.drawLine(Offset(w - 1.5, 1.5), Offset(1.5, h - 1.5), p);
      case 'Circle':
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2 - 1.2, p);
      case 'Square':
        canvas.drawRect(Rect.fromLTWH(1.5, 1.5, w - 3, h - 3), p);
      case 'Triangle':
        canvas.drawPath(
            Path()
              ..moveTo(w / 2, 1)
              ..lineTo(w - 1, h - 2)
              ..lineTo(1, h - 2)
              ..close(),
            p);
    }
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.shape != shape || old.color != color;
}

class CodeBox extends StatelessWidget {
  const CodeBox(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.text2),
            const SizedBox(width: 8)
          ],
          Flexible(
            child: SelectableText(text,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.gold)),
          ),
        ]),
      );
}

class CheatCard extends StatelessWidget {
  const CheatCard({
    super.key,
    required this.cheat,
    required this.platform,
    required this.favorites,
    this.gameTitle,
    this.accent,
  });
  final Cheat cheat;
  final Platform platform;
  final Favorites favorites;
  final String? gameTitle;
  final Color? accent;

  void _copy(BuildContext context) {
    final text = cheat.copyText(platform);
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('Copied: ${cheat.name}'),
          duration: const Duration(milliseconds: 1400)));
  }

  @override
  Widget build(BuildContext context) {
    final buttons = cheat.buttons(platform);
    final fav = favorites.contains(cheat.id);
    final showPc = platform == Platform.pc && cheat.pc != null;
    final ac = accent ?? AppColors.accent;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1A29), AppColors.surface],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: cheat.soon ? null : () => _copy(context),
          child: Stack(children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: cheat.soon ? AppColors.accent2 : ac),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 4, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (gameTitle != null)
                            Text(gameTitle!.toUpperCase(),
                                style: TextStyle(
                                    color: ac,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          Text(cheat.name,
                              style: const TextStyle(
                                  fontSize: 16.5, fontWeight: FontWeight.w800, height: 1.2)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: ac.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(cheat.category.toUpperCase(),
                                style: TextStyle(
                                    color: Color.lerp(ac, Colors.white, 0.35),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8)),
                          ),
                        ]),
                      ),
                      if (!cheat.soon)
                        IconButton(
                          tooltip: 'Copy',
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          onPressed: () => _copy(context),
                        ),
                      IconButton(
                        tooltip: fav ? 'Remove favourite' : 'Add favourite',
                        icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded,
                            color: fav ? AppColors.gold : null),
                        onPressed: () => favorites.toggle(cheat.id),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _body(buttons, showPc),
                    ),
                    if (cheat.unlock != null) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.lock_open_rounded, size: 14, color: AppColors.text2),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Unlock: ${cheat.unlock}',
                              style: const TextStyle(color: AppColors.text2, fontSize: 12)),
                        ),
                      ]),
                    ],
                    if (cheat.note != null) ...[
                      const SizedBox(height: 6),
                      Text(cheat.note!,
                          style: const TextStyle(
                              color: Color(0xFFFFB74D), fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ]),
                ),
            ]),
        ),
      ),
    );
  }

  Widget _body(List<String>? buttons, bool showPc) {
    if (cheat.soon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.accent2),
          SizedBox(width: 8),
          Text('Code coming soon',
              style: TextStyle(color: AppColors.accent2, fontWeight: FontWeight.w600)),
        ]),
      );
    }
    final parts = <Widget>[];
    if (showPc) {
      parts.add(CodeBox(cheat.pc!, icon: Icons.keyboard_rounded));
    } else if (buttons != null) {
      parts.add(Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final t in buttons) ButtonCap(t, platform: platform)]));
    }
    if (cheat.phone != null) {
      if (parts.isNotEmpty) parts.add(const SizedBox(height: 8));
      parts.add(CodeBox(cheat.phone!, icon: Icons.phone_iphone_rounded));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: parts);
  }
}

class Disclaimer extends StatelessWidget {
  const Disclaimer({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          'Unofficial fan app, not affiliated with Rockstar Games or Take-Two.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.text2, fontSize: 12),
        ),
      );
}
