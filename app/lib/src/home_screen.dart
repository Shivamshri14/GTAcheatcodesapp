import 'package:material_ui/material_ui.dart';

import 'about_screen.dart';
import 'ads.dart';
import 'favorites.dart';
import 'favorites_screen.dart';
import 'game_screen.dart';
import 'icons.dart';
import 'models.dart';
import 'search_screen.dart';
import 'stickers_screen.dart';
import 'theme.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.data, required this.favorites});
  final CheatData data;
  final Favorites favorites;

  void _push(BuildContext context, Widget w) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BannerAdBar(),
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
              child: Row(children: [
                const AppLogo(size: 58),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('CHEAT CODES',
                        style: TextStyle(
                            fontFamily: 'Anton', fontSize: 30, height: 1.0, color: Colors.white)),
                    ShaderMask(
                      shaderCallback: (r) =>
                          const LinearGradient(colors: [AppColors.accent, AppColors.gold])
                              .createShader(r),
                      child: const Text('FOR GTA',
                          style: TextStyle(
                              fontFamily: 'Anton', fontSize: 30, height: 1.1, color: Colors.white)),
                    ),
                  ]),
                ),
                IconButton(
                  tooltip: 'About',
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () => _push(context, AboutScreen(data: data)),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: GestureDetector(
                onTap: () => _push(context, SearchScreen(data: data, favorites: favorites)),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search all cheats (e.g. tank, money, HESOYAM)',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(children: [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.star_rounded,
                    color: AppColors.gold,
                    label: 'Favourites',
                    onTap: () =>
                        _push(context, FavoritesScreen(data: data, favorites: favorites)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.emoji_emotions_rounded,
                    color: const Color(0xFF4FE3B0),
                    label: 'WhatsApp Stickers',
                    onTap: () => _push(context, const StickersScreen()),
                  ),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: data.games.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final g = data.games[data.games.length - 1 - i];
                return GameCard(
                  game: g,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(
                          builder: (_) => GameScreen(game: g, favorites: favorites)))
                      .then((_) => Ads.instance.maybeShowInterstitial()),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: Disclaimer()),
        ]),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile(
      {required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      );
}

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, required this.onTap});
  final Game game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = game.color;
    final isNew = game.id == 'vi';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 156,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(game.image, fit: BoxFit.cover, alignment: Alignment.center),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.92),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: c),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _pill('${game.year}'),
                  if (isNew) ...[
                    const SizedBox(width: 6),
                    _pill('NEW', bg: c, fg: Colors.black),
                  ],
                ]),
                const Spacer(),
                Text(game.title.toUpperCase(),
                    style: const TextStyle(
                        fontFamily: 'Anton',
                        fontSize: 30,
                        height: 1.0,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
                const SizedBox(height: 4),
                Row(children: [
                  Flexible(
                    child: Text(game.city,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5)),
                  ),
                  const SizedBox(width: 10),
                  for (final p in game.platforms)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PlatformIcon(p, size: 14, color: Colors.white70),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                    child: Text('${game.codeCount} codes',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _pill(String t, {Color? bg, Color? fg}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: bg ?? Colors.black.withValues(alpha: 0.45),
            border: bg == null ? Border.all(color: Colors.white24) : null,
            borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg ?? Colors.white)),
      );
}

/// The original app's "Cheat Code" neon logo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.24),
          boxShadow: [
            BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 14),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset('assets/icon/logo.jpg', fit: BoxFit.cover),
      );
}
