import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme.dart';

class MoreApp {
  const MoreApp(this.name, this.tagline, this.icon, this.url);
  final String name;
  final String tagline;
  final String icon;
  final String url;
}

/// Links carried over from the original app's "More Apps" menu, plus Snap Art Puzzle.
const moreApps = [
  MoreApp('Snap Art Puzzle', 'Turn photos into jigsaw puzzles', 'assets/apps/snapart.png',
      'https://play.google.com/store/apps/details?id=com.snapart.puzzle'),
  MoreApp('Love Calculator', 'Test your love match', 'assets/apps/lovemeter.png',
      'https://play.google.com/store/apps/details?id=com.shivam.lovemeter'),
  MoreApp('Tic Tac Toe', 'Classic neon X and O', 'assets/apps/tictactoe.png',
      'https://play.google.com/store/apps/details?id=com.shivamshri.tictactoeTTT&hl=en&gl=IN'),
];

const contactEmail = 'developer.shivam07@gmail.com';
const instagramUrl = 'https://www.instagram.com/_heysaksham/';

Future<void> openLink(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
      .catchError((_) => false);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open the link.')));
  }
}

class MoreAppsSection extends StatelessWidget {
  const MoreAppsSection({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MORE APPS', style: display.copyWith(fontSize: 20, letterSpacing: 0.6)),
          const SizedBox(height: 10),
          for (final a in moreApps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openLink(context, a.url),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(a.icon, width: 52, height: 52),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(a.tagline,
                              style: const TextStyle(color: AppColors.text2, fontSize: 12)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('GET',
                            style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => openLink(context, 'mailto:$contactEmail'),
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Mail us'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => openLink(context, instagramUrl),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Instagram'),
              ),
            ),
          ]),
        ]),
      );
}
