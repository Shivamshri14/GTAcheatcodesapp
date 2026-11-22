import 'dart:convert';

import 'package:flutter/services.dart';

enum Platform { ps, xbox, pc }

extension PlatformX on Platform {
  String get key => name;
  String get label => switch (this) {
        Platform.ps => 'PlayStation',
        Platform.xbox => 'Xbox',
        Platform.pc => 'PC',
      };
}

class Cheat {
  Cheat({
    required this.gameId,
    required this.name,
    required this.category,
    this.ps,
    this.xbox,
    this.pc,
    this.phone,
    this.note,
    this.unlock,
    this.soon = false,
  });

  factory Cheat.fromJson(String gameId, Map<String, dynamic> j) => Cheat(
        gameId: gameId,
        name: j['name'] as String,
        category: j['cat'] as String,
        ps: (j['ps'] as List?)?.cast<String>(),
        xbox: (j['xbox'] as List?)?.cast<String>(),
        pc: j['pc'] as String?,
        phone: j['phone'] as String?,
        note: j['note'] as String?,
        unlock: (j['unlock'] as String?)?.isEmpty ?? true ? null : j['unlock'] as String,
        soon: j['soon'] == true,
      );

  final String gameId;
  final String name;
  final String category;
  final List<String>? ps;
  final List<String>? xbox;
  final String? pc;
  final String? phone;
  final String? note;
  final String? unlock;
  final bool soon;

  String get id => '$gameId::$name';

  List<String>? buttons(Platform p) => switch (p) {
        Platform.ps => ps,
        Platform.xbox => xbox,
        Platform.pc => null,
      };

  /// Whether this cheat has something to show on [p].
  bool availableOn(Platform p) {
    if (soon) return p != Platform.pc;
    if (phone != null) return true;
    return switch (p) {
      Platform.ps => ps != null,
      Platform.xbox => xbox != null,
      Platform.pc => pc != null,
    };
  }

  /// Plain text for the clipboard.
  String copyText(Platform p) {
    final b = buttons(p);
    if (p == Platform.pc && pc != null) return pc!;
    if (b != null) return b.join(', ');
    return phone ?? pc ?? '';
  }
}

class Game {
  Game({
    required this.id,
    required this.title,
    required this.year,
    required this.city,
    required this.color,
    required this.platforms,
    required this.how,
    required this.source,
    required this.cheats,
  });

  factory Game.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as String;
    return Game(
      id: id,
      title: j['title'] as String,
      year: j['year'] as int,
      city: j['city'] as String,
      color: Color(int.parse(j['color'] as String)),
      platforms: (j['platforms'] as List)
          .map((e) => Platform.values.firstWhere((p) => p.key == e))
          .toList(),
      how: (j['how'] as Map).cast<String, String>(),
      source: j['source'] as String,
      cheats: (j['cheats'] as List)
          .map((e) => Cheat.fromJson(id, e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String title;
  final int year;
  final String city;
  final Color color;
  final List<Platform> platforms;
  final Map<String, String> how;
  final String source;
  final List<Cheat> cheats;

  /// Card / hero background (assets/games/ID.jpg).
  String get image => 'assets/games/$id.jpg';

  int get codeCount => cheats.where((c) => !c.soon).length;
  int get soonCount => cheats.where((c) => c.soon).length;
}

class CheatData {
  CheatData(this.games, this.updated);
  final List<Game> games;
  final String updated;

  static Future<CheatData> load() async {
    final raw = await rootBundle.loadString('assets/data/cheats.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return CheatData(
      (j['games'] as List)
          .map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList(),
      j['updated'] as String,
    );
  }

  Game game(String id) => games.firstWhere((g) => g.id == id);
}
