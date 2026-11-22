import 'package:material_ui/material_ui.dart';

import 'ads.dart';
import 'favorites.dart';
import 'icons.dart';
import 'models.dart';
import 'theme.dart';
import 'widgets.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.game, required this.favorites});
  final Game game;
  final Favorites favorites;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: game.platforms.length,
      child: Scaffold(
        bottomNavigationBar: const BannerAdBar(),
        body: NestedScrollView(
          headerSliverBuilder: (context, inner) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: AppColors.bg,
                forceElevated: inner,
                title: inner ? Text(game.title.toUpperCase()) : null,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _Hero(game: game),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: _PlatformPills(game: game),
                ),
              ),
            ),
          ],
          body: TabBarView(children: [
            for (final p in game.platforms)
              _PlatformList(game: game, platform: p, favorites: favorites),
          ]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.game});
  final Game game;
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        Image.asset(game.image, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.15),
                AppColors.bg.withValues(alpha: 0.92),
                AppColors.bg,
              ],
              stops: const [0, 0.35, 0.78, 1],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 74,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 4, height: 14, color: game.color),
              const SizedBox(width: 8),
              Text('${game.year} · ${game.city.toUpperCase()}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1)),
            ]),
            const SizedBox(height: 4),
            Text(game.title.toUpperCase(),
                style: const TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 40,
                    height: 1.0,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 12, color: Colors.black)])),
            const SizedBox(height: 4),
            Text(
                game.soonCount > 0
                    ? '${game.codeCount} confirmed codes · ${game.soonCount} coming soon'
                    : '${game.codeCount} cheat codes',
                style: TextStyle(color: game.color, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      ]);
}

/// Segmented pill tabs with platform logos.
class _PlatformPills extends StatelessWidget {
  const _PlatformPills({required this.game});
  final Game game;
  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => TabBar(
            dividerHeight: 0,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            indicatorSize: TabBarIndicatorSize.tab,
            splashBorderRadius: BorderRadius.circular(22),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                  colors: [game.color, Color.lerp(game.color, Colors.white, 0.25)!]),
              boxShadow: [BoxShadow(color: game.color.withValues(alpha: 0.4), blurRadius: 10)],
            ),
            labelColor: Colors.black,
            unselectedLabelColor: AppColors.text2,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              for (final (i, p) in game.platforms.indexed)
                Tab(
                  height: 40,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    PlatformIcon(p,
                        size: 16,
                        color: controller.index == i ? Colors.black : AppColors.text2),
                    const SizedBox(width: 6),
                    Flexible(child: Text(p.label, overflow: TextOverflow.fade, softWrap: false)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformList extends StatefulWidget {
  const _PlatformList({required this.game, required this.platform, required this.favorites});
  final Game game;
  final Platform platform;
  final Favorites favorites;
  @override
  State<_PlatformList> createState() => _PlatformListState();
}

class _PlatformListState extends State<_PlatformList>
    with AutomaticKeepAliveClientMixin {
  String? _cat;
  String _q = '';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final g = widget.game;
    final all = g.cheats.where((c) => c.availableOn(widget.platform)).toList();
    final cats = <String>{for (final c in all) c.category}.toList();
    final q = _q.toLowerCase();
    final list = all
        .where((c) => _cat == null || c.category == _cat)
        .where((c) =>
            q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            (c.pc?.toLowerCase().contains(q) ?? false))
        .toList();
    final withCode = list.where((c) => !c.soon).toList();
    final soon = list.where((c) => c.soon).toList();
    return AnimatedBuilder(
      animation: widget.favorites,
      builder: (context, _) => CustomScrollView(
        key: PageStorageKey(widget.platform.key),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList(delegate: SliverChildListDelegate([
          _HowTo(text: g.how[widget.platform.key] ?? '', color: g.color),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: 'Search ${g.title} cheats',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip('All', _cat == null, () => setState(() => _cat = null)),
              for (final c in cats)
                _chip(c, _cat == c, () => setState(() => _cat = _cat == c ? null : c)),
            ]),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: Text('No cheats match.', style: TextStyle(color: AppColors.text2))),
            ),
          for (final c in withCode)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CheatCard(cheat: c, platform: widget.platform, favorites: widget.favorites, accent: g.color),
            ),
          if (soon.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
              child: Text('CODES COMING SOON (${soon.length})',
                  style: display.copyWith(fontSize: 18, color: AppColors.accent2)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                'These cheats exist in the game, but no code has been confirmed by '
                'reliable sources yet. We only add a code once it is verified.',
                style: TextStyle(color: AppColors.text2, fontSize: 12),
              ),
            ),
            for (final c in soon)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:
                    CheatCard(cheat: c, platform: widget.platform, favorites: widget.favorites, accent: g.color),
              ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Sources: ${g.source}',
                style: const TextStyle(color: AppColors.text2, fontSize: 11)),
          ),
          const Disclaimer(),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: widget.game.color.withValues(alpha: 0.35),
          showCheckmark: false,
        ),
      );
}

class _HowTo extends StatelessWidget {
  const _HowTo({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.lightbulb_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.35))),
        ]),
      );
}
