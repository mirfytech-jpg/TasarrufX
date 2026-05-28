import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/models.dart';
import '../providers/butce_provider.dart';
import '../utils/formatters.dart';
import '../utils/ad_manager.dart';

class ButceScreen extends StatefulWidget {
  const ButceScreen({super.key});

  @override
  State<ButceScreen> createState() => _ButceScreenState();
}

class _ButceScreenState extends State<ButceScreen> {
  late final TextEditingController _gelirCtrl;
  final _gelirFocus = FocusNode();
  ButceProvider? _butceVM;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _gelirCtrl = TextEditingController();
    _loadInterstitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Yalnızca ilk çağrıda: listener ekle ve controller'ı doldur.
    if (_butceVM == null) {
      _butceVM = context.read<ButceProvider>();
      if (_butceVM!.aylikGelir > 0) {
        _gelirCtrl.text = _butceVM!.aylikGelir.toStringAsFixed(0);
      }
      _butceVM!.addListener(_gelirSync);
    }
  }

  /// ButceProvider değiştiğinde controller'ı senkronize eder.
  /// Yalnızca gelir dışarıdan sıfırlandığında (tüm verileri sil) devreye girer.
  void _gelirSync() {
    if (!mounted) return;
    final gelir = _butceVM!.aylikGelir;
    final controllerGelir = double.tryParse(_gelirCtrl.text) ?? 0;
    if (gelir == 0 && controllerGelir != 0) {
      _gelirCtrl.text = '';
    }
  }

  @override
  void dispose() {
    _butceVM?.removeListener(_gelirSync);
    _gelirCtrl.dispose();
    _gelirFocus.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
              if (mounted) _goesterGiderSheet();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
              if (mounted) _goesterGiderSheet();
            },
          );
        },
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Sadece yeni gider eklemede reklam göster; düzenlemede direkt aç.
  void _giderEkleSheet({Gider? duzenle}) {
    if (duzenle == null && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      _goesterGiderSheet(duzenle: duzenle);
    }
  }

  void _goesterGiderSheet({Gider? duzenle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GiderSheet(duzenle: duzenle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ButceProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: GestureDetector(
        onTap: () => _gelirFocus.unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Bütçem'),
              floating: true,
              backgroundColor: const Color(0xFFF2F2F7),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, size: 28),
                  onPressed: () => _giderEkleSheet(),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // Gelir Kartı
                  _AppCard(child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Aylık Net Gelir',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Text('₺',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF30D158))),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: _gelirCtrl,
                            focusNode: _gelirFocus,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                            ),
                            onChanged: (v) {
                              final temiz = v.replaceAll(RegExp(r'[^0-9]'), '');
                              if (temiz != v) {
                                _gelirCtrl.text = temiz;
                                _gelirCtrl.selection = TextSelection.fromPosition(
                                    TextPosition(offset: temiz.length));
                              }
                              vm.gelirGuncelle(double.tryParse(temiz) ?? 0);
                            },
                          ),
                        ),
                      ]),
                      const Text('Vergi ve kesintiler sonrası eline geçen miktar',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                    ]),
                  )),

                  const SizedBox(height: 16),

                  // Tasarruf Özeti
                  if (vm.aylikGelir > 0) ...[
                    _AppCard(child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        Row(children: [
                          Expanded(child: _TasarrufSatir(
                            baslik: 'Toplam Gider',
                            deger: TLFormatter.format(vm.toplamGider),
                            ikon: Icons.arrow_upward_rounded,
                            renk: const Color(0xFFFF3B30),
                          )),
                          const VerticalDivider(width: 1, thickness: 1),
                          Expanded(child: _TasarrufSatir(
                            baslik: 'Aylık Tasarruf',
                            deger: TLFormatter.format(vm.aylikTasarruf),
                            ikon: Icons.arrow_downward_rounded,
                            renk: const Color(0xFF30D158),
                          )),
                          const VerticalDivider(width: 1, thickness: 1),
                          Expanded(child: _TasarrufSatir(
                            baslik: 'Tasarruf Oranı',
                            deger: '%${vm.tasarrufOrani.toInt()}',
                            ikon: Icons.pie_chart_rounded,
                            renk: const Color(0xFFFF9500),
                          )),
                        ]),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (vm.tasarrufOrani / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE5E5EA),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF30D158)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Yıllık tahmini tasarruf: ${TLFormatter.format(vm.yillikTasarruf)}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF30D158)),
                        ),
                      ]),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Giderler Kartı
                  _AppCard(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                        child: Text('Aylık Giderler',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                      if (vm.giderler.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: _BosEkran(
                            ikon: Icons.credit_card_rounded,
                            baslik: 'Gider Eklenmedi',
                            aciklama: 'Kira, fatura gibi sabit giderlerinizi ekleyin.',
                          ),
                        )
                      else ...[
                        ...vm.giderler.asMap().entries.map((entry) {
                          final g = entry.value;
                          final isLast = entry.key == vm.giderler.length - 1;
                          return Column(children: [
                            Dismissible(
                              key: ValueKey(g.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete_rounded, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Gideri Sil'),
                                    content: Text('${g.ad} silinsin mi?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('İptal')),
                                      TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Sil',
                                              style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => vm.giderSil(g.id!),
                              child: ListTile(
                                onTap: () => _giderEkleSheet(duzenle: g),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  child: Icon(g.kategori.ikon, color: Colors.red, size: 18),
                                ),
                                title: Text(g.ad,
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w500)),
                                subtitle: Text(g.kategori.ad,
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF8E8E93))),
                                trailing: Text(TLFormatter.format(g.tutar),
                                    style: const TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, indent: 70),
                          ]);
                        }),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Toplam',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600)),
                              Text(TLFormatter.format(vm.toplamGider),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF3B30))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )),

                  // Motivasyon mesajı
                  if (vm.aylikGelir > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        const Icon(Icons.lightbulb_rounded, color: Color(0xFFFF9500)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(vm.tasarrufMesaji,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF8E8E93)))),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasarrufSatir extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;

  const _TasarrufSatir({
    required this.baslik,
    required this.deger,
    required this.ikon,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(ikon, color: renk, size: 16),
      const SizedBox(height: 4),
      Text(deger,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: renk),
          overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Text(baslik,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
          textAlign: TextAlign.center),
    ]);
  }
}

// ─── Gider Ekleme Sheet ───────────────────────────────────────────────────────

class _GiderSheet extends StatefulWidget {
  final Gider? duzenle;
  const _GiderSheet({this.duzenle});

  @override
  State<_GiderSheet> createState() => _GiderSheetState();
}

class _GiderSheetState extends State<_GiderSheet> {
  late final TextEditingController _adCtrl;
  late final TextEditingController _tutarCtrl;
  late GiderKategori _kategori;

  @override
  void initState() {
    super.initState();
    final g = widget.duzenle;
    _adCtrl = TextEditingController(text: g?.ad ?? '');
    _tutarCtrl = TextEditingController(
        text: g != null ? g.tutar.toStringAsFixed(0) : '');
    _kategori = g?.kategori ?? GiderKategori.konut;
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _tutarCtrl.dispose();
    super.dispose();
  }

  void _kaydet() {
    final ad = _adCtrl.text.trim();
    final tutar = double.tryParse(_tutarCtrl.text) ?? 0;
    if (ad.isEmpty || tutar <= 0) return;

    final vm = context.read<ButceProvider>();
    if (widget.duzenle != null) {
      vm.giderGuncelle(Gider(
          id: widget.duzenle!.id, ad: ad, tutar: tutar, kategori: _kategori));
    } else {
      vm.giderEkle(ad: ad, tutar: tutar, kategori: _kategori);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(widget.duzenle != null ? 'Gideri Düzenle' : 'Gider Ekle',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            DropdownButtonFormField<GiderKategori>(
              value: _kategori,
              decoration: _inputDecor('Kategori'),
              items: GiderKategori.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.ad)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),

            TextField(controller: _adCtrl,
                decoration: _inputDecor('Gider Adı (örn: Kira)')),
            const SizedBox(height: 12),

            TextField(
              controller: _tutarCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecor('Tutar (₺)'),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _kaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF30D158),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.duzenle != null ? 'Güncelle' : 'Ekle',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E5EA))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF30D158), width: 2)),
  );
}

class _AppCard extends StatelessWidget {
  final Widget child;
  const _AppCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BosEkran extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String aciklama;

  const _BosEkran({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        Icon(ikon, size: 44, color: const Color(0xFFD1D1D6)),
        const SizedBox(height: 10),
        Text(baslik,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
        const SizedBox(height: 4),
        Text(aciklama,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFFAEAEB2))),
      ]),
    );
  }
}
