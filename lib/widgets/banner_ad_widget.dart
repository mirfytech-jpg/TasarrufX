import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Küçük banner reklam widget'ı.
/// Yüklenmezse ya da hata olursa 0 yükseklikte SizedBox döner — layout bozulmaz.
class BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  const BannerAdWidget({super.key, required this.adUnitId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _ad = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      color: const Color(0xFFF2F2F7),
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      width: double.infinity,
      height: _ad!.size.height.toDouble() + 12,
      child: AdWidget(ad: _ad!),
    );
  }
}
