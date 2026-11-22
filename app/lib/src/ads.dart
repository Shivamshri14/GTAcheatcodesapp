import 'dart:async';
import 'dart:io' show Platform;

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads_config.dart';

/// Consent (UMP) + Mobile Ads init + capped interstitial and app-open ads.
class Ads with WidgetsBindingObserver {
  Ads._();
  static final instance = Ads._();

  /// Off in widget tests and on non-Android platforms.
  static final bool supported =
      !Platform.environment.containsKey('FLUTTER_TEST') && Platform.isAndroid;

  bool _initStarted = false;
  bool _ready = false;
  bool _firstOpen = true;
  bool _pastSplash = false;
  bool _observingLifecycle = false;
  bool _showingFullScreen = false;
  DateTime? _lastShown;
  DateTime? _lastAppOpenShown;
  DateTime? _appOpenLoadedAt;
  InterstitialAd? _inter;
  AppOpenAd? _appOpen;
  final ValueNotifier<bool> ready = ValueNotifier(false);

  static const _lastAppOpenPref = 'last_app_open_ms';
  static const _appOpenMaxAge = Duration(hours: 4);

  Future<void> init() async {
    if (!supported || _initStarted) return;
    _initStarted = true;
    final prefs = await SharedPreferences.getInstance();
    final launches = (prefs.getInt('launches') ?? 0) + 1;
    await prefs.setInt('launches', launches);
    _firstOpen = launches <= 1;
    final lastMs = prefs.getInt(_lastAppOpenPref);
    if (lastMs != null) {
      _lastAppOpenShown = DateTime.fromMillisecondsSinceEpoch(lastMs);
    }

    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        if (!done.isCompleted) done.complete();
      },
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future.timeout(const Duration(seconds: 12), onTimeout: () {});
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    _ready = true;
    ready.value = true;
    _loadInterstitial();
    _loadAppOpen();
  }

  /// Call once the Flutter splash has been replaced by the home screen.
  /// Idempotent. App-open ads are not shown until this fires (and the splash
  /// fade-out has finished).
  void onSplashComplete() {
    if (_pastSplash) return;
    _pastSplash = true;
    if (supported && !_observingLifecycle) {
      _observingLifecycle = true;
      WidgetsBinding.instance.addObserver(this);
    }
    // Wait out the splash fade (~450ms) so the ad never covers the splash.
    Future<void>.delayed(const Duration(milliseconds: 500), maybeShowAppOpen);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) maybeShowAppOpen();
  }

  /// Whether the "Privacy settings" entry (EEA/UK users) should be shown.
  Future<bool> privacyOptionsRequired() async {
    if (!supported) return false;
    return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  void showPrivacyOptions() {
    if (!supported) return;
    ConsentForm.showPrivacyOptionsForm((_) {});
  }

  void _loadInterstitial() {
    if (!_ready || AdIds.interstitial.isEmpty) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _inter = ad,
        onAdFailedToLoad: (_) => _inter = null,
      ),
    );
  }

  void _loadAppOpen() {
    if (!_ready || AdIds.appOpen.isEmpty) return;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpen = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (_) {
          _appOpen = null;
          _appOpenLoadedAt = null;
        },
      ),
    );
  }

  bool get _appOpenUsable {
    final ad = _appOpen;
    final loaded = _appOpenLoadedAt;
    if (ad == null || loaded == null) return false;
    if (DateTime.now().difference(loaded) > _appOpenMaxAge) {
      ad.dispose();
      _appOpen = null;
      _appOpenLoadedAt = null;
      return false;
    }
    return true;
  }

  /// Show a preloaded app-open ad if caps allow. No-ops during splash, on the
  /// first launch, while another full-screen ad is up, or within [appOpenMinGap].
  void maybeShowAppOpen() {
    if (!_ready || !_pastSplash || _firstOpen || _showingFullScreen) return;
    if (!_appOpenUsable) {
      _loadAppOpen();
      return;
    }
    final now = DateTime.now();
    if (_lastAppOpenShown != null && now.difference(_lastAppOpenShown!) < appOpenMinGap) {
      return;
    }
    final ad = _appOpen!;
    _appOpen = null;
    _appOpenLoadedAt = null;
    _showingFullScreen = true;
    _lastAppOpenShown = now;
    unawaited(_persistLastAppOpen(now));
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _showingFullScreen = false;
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _showingFullScreen = false;
        _loadAppOpen();
      },
    );
    ad.show();
  }

  Future<void> _persistLastAppOpen(DateTime when) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAppOpenPref, when.millisecondsSinceEpoch);
  }

  /// Called when the user leaves a game page. Never on the first app open,
  /// and at most once every [interstitialMinGap].
  void maybeShowInterstitial() {
    final ad = _inter;
    if (!_ready || _firstOpen || _showingFullScreen || ad == null) return;
    final now = DateTime.now();
    if (_lastShown != null && now.difference(_lastShown!) < interstitialMinGap) return;
    _lastShown = now;
    _inter = null;
    _showingFullScreen = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _showingFullScreen = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _showingFullScreen = false;
        _loadInterstitial();
      },
    );
    ad.show();
  }
}

/// Anchored adaptive banner; takes no space until an ad loads.
class BannerAdBar extends StatefulWidget {
  const BannerAdBar({super.key});
  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  BannerAd? _ad;
  bool _loaded = false;
  int? _width;

  @override
  void initState() {
    super.initState();
    Ads.instance.ready.addListener(_maybeLoad);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    if (!Ads.supported || !Ads.instance.ready.value || !mounted) return;
    final w = MediaQuery.sizeOf(context).width.truncate();
    if (_ad != null && _width == w) return;
    _width = w;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(w);
    if (size == null || !mounted) return;
    await _ad?.dispose();
    _loaded = false;
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    Ads.instance.ready.removeListener(_maybeLoad);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
