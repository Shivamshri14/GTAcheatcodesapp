import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final data = jsonDecode(File('assets/data/cheats.json').readAsStringSync())
      as Map<String, dynamic>;
  final games = (data['games'] as List).cast<Map<String, dynamic>>();
  const ps = {'Up', 'Down', 'Left', 'Right', 'Cross', 'Circle', 'Square', 'Triangle',
    'L1', 'R1', 'L2', 'R2'};
  const xb = {'Up', 'Down', 'Left', 'Right', 'A', 'B', 'X', 'Y', 'LB', 'RB', 'LT', 'RT'};

  test('eight games in release order', () {
    expect(games.map((g) => g['id']), ['gta3', 'vc', 'sa', 'lcs', 'vcs', 'iv', 'v', 'vi']);
  });

  test('every button is a valid controller input', () {
    for (final g in games) {
      for (final c in (g['cheats'] as List).cast<Map<String, dynamic>>()) {
        for (final t in (c['ps'] as List? ?? const [])) {
          expect(ps.contains(t), isTrue, reason: '${g['id']} ${c['name']} $t');
        }
        for (final t in (c['xbox'] as List? ?? const [])) {
          expect(xb.contains(t), isTrue, reason: '${g['id']} ${c['name']} $t');
        }
      }
    }
  });

  test('no duplicate cheat names inside a game', () {
    for (final g in games) {
      final names = (g['cheats'] as List).map((c) => c['name']).toList();
      expect(names.toSet().length, names.length, reason: g['id'] as String);
    }
  });

  test('GTA 6: D-pad only, no PC, coming-soon entries carry no code', () {
    final vi = games.firstWhere((g) => g['id'] == 'vi');
    expect(vi['platforms'], ['ps', 'xbox']);
    final cheats = (vi['cheats'] as List).cast<Map<String, dynamic>>();
    expect(cheats.length, 61);
    for (final c in cheats) {
      if (c['soon'] == true) {
        expect(c.containsKey('ps') || c.containsKey('xbox'), isFalse);
      } else {
        expect(c['ps'], c['xbox']);
        for (final t in c['ps'] as List) {
          expect(['Up', 'Down', 'Left', 'Right'].contains(t), isTrue);
        }
      }
    }
  });

  test('GTA V phone numbers spell the PC word', () {
    const k = {'A': 2, 'B': 2, 'C': 2, 'D': 3, 'E': 3, 'F': 3, 'G': 4, 'H': 4, 'I': 4,
      'J': 5, 'K': 5, 'L': 5, 'M': 6, 'N': 6, 'O': 6, 'P': 7, 'Q': 7, 'R': 7, 'S': 7,
      'T': 8, 'U': 8, 'V': 8, 'W': 9, 'X': 9, 'Y': 9, 'Z': 9};
    final v = games.firstWhere((g) => g['id'] == 'v');
    for (final c in (v['cheats'] as List).cast<Map<String, dynamic>>()) {
      final digits = (c['pc'] as String).split('').map((ch) => k[ch]?.toString() ?? ch).join();
      expect((c['phone'] as String).replaceAll('-', ''), '1999$digits');
    }
  });
}
