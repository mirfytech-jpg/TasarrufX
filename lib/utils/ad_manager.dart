import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // ─── Production Ad Unit IDs ───────────────────────────────────────────────
  static const String bannerAnaSayfaId =
      'ca-app-pub-4055315573310307/7857224155';
  static const String bannerSimulatorId =
      'ca-app-pub-4055315573310307/4903757757';
  static const String interstitialId =
      'ca-app-pub-4055315573310307/5231060817';

  // ─── Başlatma ─────────────────────────────────────────────────────────────
  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  // ─── Interstitial yükle ───────────────────────────────────────────────────
  static Future<InterstitialAd?> loadInterstitial() async {
    final completer = Completer<InterstitialAd?>();
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: completer.complete,
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );
    return completer.future;
  }
}
