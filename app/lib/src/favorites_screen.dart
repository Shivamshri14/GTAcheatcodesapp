import 'package:material_ui/material_ui.dart';

import 'favorites.dart';
import 'models.dart';
import 'platform_switch.dart';
import 'theme.dart';
import 'widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.data, required this.favorites});
  final CheatData data;
  final Favorites favorites;
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Platform _p = Platform.ps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAVOURITES')),
      body: AnimatedBuilder(
        animation: widget.favorites,
        builder: (context, _) {
          final items = <(Game, Cheat)>[
            for (final g in widget.data.games.reversed)
              for (final c in g.cheats)
                if (widget.favorites.contains(c.id)) (g, c),
          ];
          final shown = items.where((e) => e.$2.availableOn(_p)).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              PlatformSwitch(value: _p, onChanged: (p) => setState(() => _p = p)),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(children: [
                    Icon(Icons.star_border_rounded, size: 48, color: AppColors.text2),
                    SizedBox(height: 12),
                    Text('Tap the star on any cheat to save it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.text2)),
                  ]),
                )
              else if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('None of your favourites are on ${_p.label}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.text2)),
                ),
              for (final (g, c) in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CheatCard(
                    cheat: c,
                    platform: _p,
                    favorites: widget.favorites,
                    gameTitle: g.title,
                    accent: g.color,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
