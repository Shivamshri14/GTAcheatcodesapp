/// AdMob configuration. Swap IDs here.
///
/// Build with `--dart-define=ADS_MODE=prod` (and env ADS_MODE=prod for Gradle, which
/// picks the AdMob *app* ID from android/admob.properties) to use the real IDs.
/// Any other build (e.g. the TEST APK) uses Google's public test IDs.
library;

const adsMode = String.fromEnvironment('ADS_MODE', defaultValue: 'test');
const isProdAds = adsMode == 'prod';

class AdIds {
  // Current AdMob account (publisher ca-app-pub-2601502034384849).
  static const _prodBanner = 'ca-app-pub-2601502034384849/8546291468';
  static const _prodInterstitial = 'ca-app-pub-2601502034384849/7765123616';
  static const _prodAppOpen = 'ca-app-pub-2601502034384849/5925977071';

  // Google's official Android test units.
  static const _testBanner = 'ca-app-pub-3940256099942544/9214589741'; // adaptive banner
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testAppOpen = 'ca-app-pub-3940256099942544/9257395921';

  static String get banner => isProdAds ? _prodBanner : _testBanner;
  static String get interstitial => isProdAds ? _prodInterstitial : _testInterstitial;
  static String get appOpen => isProdAds ? _prodAppOpen : _testAppOpen;
}

/// Interstitial frequency cap (when leaving a game page).
const interstitialMinGap = Duration(minutes: 3);

/// App-open frequency cap: skip the first launch, then at most once per this
/// gap when the app comes to the foreground. Never shown over the splash.
const appOpenMinGap = Duration(hours: 4);
