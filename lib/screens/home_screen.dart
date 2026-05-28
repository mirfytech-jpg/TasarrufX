import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/varlik_provider.dart';
import '../providers/butce_provider.dart';
import '../providers/app_prefs_provider.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AlintıModel? _alintilar;

  @override
  void initState() {
    super.initState();
    _alintiYukle();
  }

  Future<void> _alintiYukle() async {
    try {
      final data = await rootBundle.loadString('Resources/alintilar.json');
      final liste = (jsonDecode(data) as List)
          .map((j) => AlintıModel.fromJson(j as Map<String, dynamic>))
          .toList();
      if (liste.isNotEmpty && mounted) {
        final gun = DateTime.now().dayOfYear;
        setState(() => _alintilar = liste[(gun - 1) % liste.length]);
      }
    } catch (_) {}
  }

  String get _selamlama {
    final saat = DateTime.now().hour;
    if (saat >= 6 && saat < 12) return 'Günaydın 👋';
    if (saat >= 12 && saat < 18) return 'İyi günler 👋';
    return 'İyi akşamlar 👋';
  }

  String _bugunTarih() {
    final now = DateTime.now();
    const aylar = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${now.day} ${aylar[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final varlikVM = context.watch<VarlikProvider>();
    final butceVM = context.watch<ButceProvider>();
    final appPrefs = context.watch<AppPrefsProvider>();
    final netDeger = varlikVM.toplamDeger;
    final hedefTutar = appPrefs.hedefTutar;
    final hedefAdi = appPrefs.hedefAdi;
    final ilerleme = hedefTutar > 0 ? (netDeger / hedefTutar).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF2F2F7),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selamlama,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                Text(_bugunTarih(),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Net Değer Kartı
                _AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    child: Column(
                      children: [
                        const Text('Net Değerim',
                            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
                        const SizedBox(height: 6),
                        Text(
                          TLFormatter.format(netDeger),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Tüm varlıklarınızın toplamı',
                            style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hızlı İstatistikler
                Row(children: [
                  Expanded(child: _IstatistikKart(
                    baslik: 'Aylık Gelir',
                    deger: TLFormatter.compact(butceVM.aylikGelir),
                    ikon: Icons.arrow_downward_rounded,
                    renk: const Color(0xFF30D158),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _IstatistikKart(
                    baslik: 'Aylık Gider',
                    deger: TLFormatter.compact(butceVM.toplamGider),
                    ikon: Icons.arrow_upward_rounded,
                    renk: const Color(0xFFFF3B30),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _IstatistikKart(
                    baslik: 'Tasarruf',
                    deger: '%${butceVM.tasarrufOrani.toInt()}',
                    ikon: Icons.pie_chart_rounded,
                    renk: const Color(0xFFFF9500),
                  )),
                ]),

                // Günün Sözü
                if (_alintilar != null) ...[
                  const SizedBox(height: 16),
                  _AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: const [
                            Icon(Icons.format_quote_rounded,
                                color: Color(0xFF30D158), size: 18),
                            SizedBox(width: 6),
                            Text('Günün Sözü',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8E8E93))),
                          ]),
                          const SizedBox(height: 10),
                          Text('"${_alintilar!.metin}"',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500, height: 1.4)),
                          const SizedBox(height: 8),
                          Text('— ${_alintilar!.yazar}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF30D158))),
                        ],
                      ),
                    ),
                  ),
                ],

                // Hedef İlerlemesi
                if (hedefTutar > 0) ...[
                  const SizedBox(height: 16),
                  _AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hedefAdi,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ilerleme,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE5E5EA),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF30D158)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(TLFormatter.compact(netDeger),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF30D158))),
                              Text('%${(ilerleme * 100).toInt()}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF8E8E93))),
                              Text(TLFormatter.compact(hedefTutar),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8E8E93))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Text(
                  'Bu uygulama yatırım tavsiyesi vermez. Tüm veriler yalnızca bilgi amaçlıdır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IstatistikKart extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;

  const _IstatistikKart({
    required this.baslik,
    required this.deger,
    required this.ikon,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(children: [
          Icon(ikon, color: renk, size: 20),
          const SizedBox(height: 6),
          Text(deger,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: renk)),
          const SizedBox(height: 2),
          Text(baslik,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
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

extension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
