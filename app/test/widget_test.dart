import 'dart:convert';
import 'dart:io';

import 'package:cheatcodes/main.dart';
import 'package:cheatcodes/src/favorites.dart';
import 'package:cheatcodes/src/models.dart';
import 'package:cheatcodes/src/stickers_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  final anton = FontLoader('Anton')
    ..addFont(rootBundle.load('assets/fonts/Anton-Regular.ttf'));
  await anton.load();
  final fa = FontLoader('FABrands')..addFont(rootBundle.load('assets/fonts/fa-brands-subset.ttf'));
  await fa.load();
  final mono = File('/usr/share/fonts/truetype/sand-box/google/Roboto Mono/RobotoMono-Italic-VariableFont_wght.ttf');
  if (mono.existsSync()) {
    final m = FontLoader('monospace')
      ..addFont(Future.value(ByteData.view(mono.readAsBytesSync().buffer)));
    await m.load();
  }
  const mi = '/home/box/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  if (File(mi).existsSync()) {
    final m = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(File(mi).readAsBytesSync().buffer)));
    await m.load();
  }
  const roboto = '/usr/share/fonts/truetype/sand-box/google/Roboto/Roboto-VariableFont_wdth,wght.ttf';
  if (File(roboto).existsSync()) {
    final r = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.view(File(roboto).readAsBytesSync().buffer)));
    await r.load();
  }
}

Future<void> _precache(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const shots = bool.fromEnvironment('SHOTS');

  testWidgets('home -> game -> copy -> favourite -> GTA 6 coming soon', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(_loadFonts);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final data = await tester.runAsync(CheatData.load);
    final fav = Favorites();
    await tester.runAsync(fav.init);
    await tester.pumpWidget(RepaintBoundary(child: CheatApp(data: data!, favorites: fav)));
    await tester.pumpAndSettle();
    expect(find.text('CHEAT CODES'), findsOneWidget);
    expect(find.text('GTA 6'.toUpperCase()), findsOneWidget);
    expect(find.textContaining('codes · '), findsNothing); // stats line removed
    await _precache(tester);
    if (shots) await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('shots/1_home.png'));

    final vScroll = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
    expect(find.text('MORE APPS'), findsNothing);
    await tester.tap(find.byTooltip('About'));
    await tester.pumpAndSettle();
    final aScroll = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down).last;
    await tester.scrollUntilVisible(find.text('Snap Art Puzzle'), 300, scrollable: aScroll);
    expect(find.text('MORE APPS'), findsOneWidget);
    expect(find.text('Love Calculator'), findsOneWidget);
    expect(find.text('Tic Tac Toe'), findsOneWidget);
    if (shots) await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('shots/0_about.png'));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('SAN ANDREAS'), 300, scrollable: vScroll);
    await tester.drag(vScroll, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAN ANDREAS'));
    await tester.pumpAndSettle();
    expect(find.text('PlayStation'), findsOneWidget);
    expect(find.text('Health, Armor & \$250,000'), findsOneWidget);
    await _precache(tester);
    if (shots) await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('shots/2_sa_ps.png'));

    await tester.tap(find.byTooltip('Copy').first);
    await tester.pump();
    expect(find.textContaining('Copied:'), findsOneWidget);
    await tester.tap(find.byTooltip('Add favourite').first);
    await tester.pump();
    expect(fav.ids.length, 1);

    await tester.tap(find.text('PC'));
    await tester.pumpAndSettle();
    expect(find.text('HESOYAM'), findsOneWidget);
    if (shots) await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('shots/3_sa_pc.png'));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('GTA 6'), -300, scrollable: vScroll);
    await tester.tap(find.text('GTA 6'.toUpperCase()));
    await tester.pumpAndSettle();
    expect(find.text('\$250,000'), findsOneWidget);
    await _precache(tester);
    if (shots) await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('shots/4_gta6.png'));
    await tester.scrollUntilVisible(find.textContaining('CODES COMING SOON'), 600,
        scrollable: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down).first);
    expect(find.text('Code coming soon'), findsWidgets);
    if (shots) await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('shots/5_gta6_soon.png'));
  });

  testWidgets('stickers screen lists 3 packs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StickersScreen()));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    expect(find.text('CHEAT CODES MEMES'), findsOneWidget);
    final idx = jsonDecode(File('assets/stickers/index.json').readAsStringSync()) as List;
    expect(idx.length, 3);
    final total = idx.fold<int>(0, (s, p) => s + (p['stickers'] as List).length);
    expect(total, greaterThanOrEqualTo(60));
    for (final p in idx) {
      expect((p['stickers'] as List).length, lessThanOrEqualTo(30));
    }
  });

  testWidgets('boot shows logo splash then home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BootApp());
    expect(find.text('CHEAT CODES FOR GTA'), findsOneWidget);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1500)));
    await tester.pumpAndSettle();
    expect(find.text('FOR GTA'), findsOneWidget);
  });
}
