import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';
import 'widgets.dart';

class StickerPack {
  StickerPack(this.id, this.name, this.stickers);
  final String id;
  final String name;
  final List<String> stickers;
}

class StickersScreen extends StatefulWidget {
  const StickersScreen({super.key});
  @override
  State<StickersScreen> createState() => _StickersScreenState();
}

class _StickersScreenState extends State<StickersScreen> {
  static const _channel = MethodChannel('cheatcodes/stickers');
  List<StickerPack> _packs = const [];
  String? _busy;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/stickers/index.json').then((s) {
      final list = (jsonDecode(s) as List)
          .map((e) => StickerPack(e['id'] as String, e['name'] as String,
              (e['stickers'] as List).cast<String>()))
          .toList();
      if (mounted) setState(() => _packs = list);
    });
  }

  Future<void> _add(StickerPack p) async {
    setState(() => _busy = p.id);
    String msg;
    try {
      final r = await _channel.invokeMethod<String>('addPack', {'id': p.id, 'name': p.name});
      msg = switch (r) {
        'not_installed' => 'WhatsApp is not installed on this phone.',
        'already_added' => 'This pack is already in WhatsApp.',
        _ => 'Opening WhatsApp…',
      };
    } on PlatformException catch (e) {
      msg = 'Could not add stickers: ${e.message ?? e.code}';
    } on MissingPluginException {
      msg = 'Stickers can only be added on Android.';
    }
    if (!mounted) return;
    setState(() => _busy = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final total = _packs.fold<int>(0, (s, p) => s + p.stickers.length);
    return Scaffold(
      appBar: AppBar(title: const Text('STICKERS')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (total > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 2),
              child: Text('$total original stickers in ${_packs.length} packs',
                  style: const TextStyle(color: AppColors.text2)),
            ),
          for (final p in _packs) ...[
            _PackCard(pack: p, busy: _busy == p.id, onAdd: () => _add(p)),
            const SizedBox(height: 16),
          ],
          const Text(
            'All sticker artwork is original fan art made for this app (characters are '
            'original designs). It does not use any official game artwork, logos or characters.',
            style: TextStyle(color: AppColors.text2, fontSize: 12),
          ),
          const Disclaimer(),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack, required this.busy, required this.onAdd});
  final StickerPack pack;
  final bool busy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Image.asset('assets/stickers/${pack.id}/tray.png', width: 44, height: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pack.name.toUpperCase(), style: display.copyWith(fontSize: 19)),
                Text('${pack.stickers.length} stickers',
                    style: const TextStyle(color: AppColors.text2, fontSize: 12)),
              ]),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: busy ? null : onAdd,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final f in pack.stickers)
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.surface2, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset('assets/stickers/${pack.id}/$f',
                      fit: BoxFit.contain, cacheWidth: 256),
                ),
            ],
          ),
        ]),
      );
}
