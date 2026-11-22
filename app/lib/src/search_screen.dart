import 'package:material_ui/material_ui.dart';

import 'favorites.dart';
import 'models.dart';
import 'platform_switch.dart';
import 'theme.dart';
import 'widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.data, required this.favorites});
  final CheatData data;
  final Favorites favorites;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';
  Platform _p = Platform.ps;

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final results = <(Game, Cheat)>[];
    if (q.length >= 2) {
      for (final g in widget.data.games.reversed) {
        for (final c in g.cheats) {
          if (!c.availableOn(_p)) continue;
          if (c.name.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q) ||
              (c.pc?.toLowerCase().contains(q) ?? false) ||
              g.title.toLowerCase().contains(q)) {
            results.add((g, c));
          }
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => _q = v),
          decoration: const InputDecoration(
            hintText: 'Search cheats in every game',
            fillColor: Colors.transparent,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.favorites,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            PlatformSwitch(value: _p, onChanged: (p) => setState(() => _p = p)),
            const SizedBox(height: 12),
            if (q.length < 2)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Type at least 2 letters: money, tank, weather, jetpack…',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.text2)),
              )
            else if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No results on this platform.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.text2)),
              ),
            for (final (g, c) in results)
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
        ),
      ),
    );
  }
}
