import 'package:material_ui/material_ui.dart';

import 'ads.dart';
import 'models.dart';
import 'more_apps.dart';
import 'theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.data});
  final CheatData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABOUT')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('CHEAT CODES FOR GTA', style: display.copyWith(fontSize: 26)),
        const SizedBox(height: 4),
        Text('Version 5.0.0 · Cheat list updated ${data.updated}',
            style: const TextStyle(color: AppColors.text2)),
        const SizedBox(height: 20),
        _card(
          Icons.gavel_rounded,
          'Disclaimer',
          'Unofficial fan app, not affiliated with Rockstar Games or Take-Two. '
              'Grand Theft Auto and GTA are trademarks of Take-Two Interactive. Game '
              'names are used only to identify which game each cheat is for.',
        ),
        _card(
          Icons.fact_check_rounded,
          'How codes are checked',
          'Codes come from established guides such as GameSpot, GameFAQs, Polygon, '
              'GamesRadar+ and GTABase. For GTA 6, a code is shown only when at least '
              'two major outlets print the same sequence; everything else is marked '
              '"coming soon". Rockstar has not published an official GTA 6 cheat list.',
        ),
        _card(
          Icons.warning_amber_rounded,
          'Before you use cheats',
          'Save first. Cheats can disable trophies and achievements, and some can\'t '
              'be turned off. In GTA 6, using a cheat blocks saving for that session.',
        ),
        _card(
          Icons.font_download_rounded,
          'Credits',
          'Display font: Anton (SIL Open Font License 1.1). Platform icons: Font Awesome '
              'Free by Fonticons, Inc. (fontawesome.com), icons licensed CC BY 4.0, font '
              'SIL OFL 1.1. Stickers: original artwork and original characters made for this '
              'app. PlayStation, Xbox and Windows are trademarks of their owners and are shown '
              'only to identify platforms.',
        ),
        const _PrivacyButton(),
        const MoreAppsSection(),
        const SizedBox(height: 16),
        const Text('Developer: Saksham Srivastava',
            style: TextStyle(color: AppColors.text2), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _card(IconData icon, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(color: AppColors.text2, height: 1.4, fontSize: 13)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

/// "Privacy settings" (UMP privacy options), only shown when required (EEA/UK).
class _PrivacyButton extends StatelessWidget {
  const _PrivacyButton();
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: Ads.instance.privacyOptionsRequired(),
        builder: (context, snap) => snap.data == true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  onPressed: Ads.instance.showPrivacyOptions,
                  icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                  label: const Text('Privacy & ad settings'),
                ),
              )
            : const SizedBox.shrink(),
      );
}
