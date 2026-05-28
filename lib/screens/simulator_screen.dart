import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../utils/formatters.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double _baslangic = 100000;
  double _aylikKatki = 1000;
  double _yillikFaiz = 15;
  int _yilSayisi = 10;

  // FV = PV*(1+r)^n + PMT*((1+r)^n - 1)/r
  double _hesapla(int yil) {
    final r = _yillikFaiz / 100 / 12;
    final n = yil * 12.0;
    final factor = pow(1 + r, n).toDouble();
    final birikmisAnapara = _baslangic * factor;
    final birikmisKatki =
        r > 0 ? _aylikKatki * (factor - 1) / r : _aylikKatki * n;
    return birikmisAnapara + birikmisKatki;
  }

  double get _gelecekDeger => _hesapla(_yilSayisi);
  double get _toplamYatirim => _baslangic + _aylikKatki * _yilSayisi * 12;
  double get _toplamGetiri => _gelecekDeger - _toplamYatirim;
  double get _buyumeOrani =>
      _toplamYatirim > 0 ? (_gelecekDeger / _toplamYatirim - 1) * 100 : 0;

  List<BuyumeNoktasi> get _grafikVerileri {
    return List.generate(_yilSayisi + 1, (yil) {
      final yatirim = _baslangic + _aylikKatki * yil * 12;
      return BuyumeNoktasi(
        yil: yil,
        toplam: _hesapla(yil),
        yatirim: yatirim,
      );
    });
  }

  List<KilometreTasi> get _kilometre {
    final hedefler = <(String, double)>[
      ('500K', 500000),
      ('1 Milyon', 1000000),
      ('5 Milyon', 5000000),
      ('10 Milyon', 10000000),
      ('2x', _baslangic * 2),
    ];

    return hedefler
        .where((h) => h.$2 > _baslangic)
        .toList()
        .map((h) {
          int? yil;
          for (int y = 1; y <= 100; y++) {
            if (_hesapla(y) >= h.$2) {
              yil = y;
              break;
            }
          }
          return KilometreTasi(etiket: h.$1, tutar: h.$2, ulasilanYil: yil);
        })
        .toList()
      ..sort((a, b) => a.tutar.compareTo(b.tutar));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Bileşik Faiz Simülatörü'),
            floating: true,
            backgroundColor: Color(0xFFF2F2F7),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Parametre Kartı
                _AppCard(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    _SliderRow(
                      baslik: 'Başlangıç Tutarı',
                      deger: _baslangic,
                      min: 10000, max: 5000000, divisions: 499,
                      label: TLFormatter.compact(_baslangic),
                      onChanged: (v) => setState(() => _baslangic = v),
                    ),
                    const Divider(height: 24),
                    _SliderRow(
                      baslik: 'Aylık Katkı',
                      deger: _aylikKatki,
                      min: 0, max: 50000, divisions: 100,
                      label: TLFormatter.compact(_aylikKatki),
                      onChanged: (v) => setState(() => _aylikKatki = v),
                    ),
                    const Divider(height: 24),
                    _LabelRow(
                      baslik: 'Yıllık Getiri Oranı',
                      deger: '%${_yillikFaiz.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: _yillikFaiz,
                      min: 1, max: 100, divisions: 198,
                      onChanged: (v) => setState(() => _yillikFaiz = v),
                    ),
                    const Divider(height: 24),
                    _LabelRow(
                      baslik: 'Yatırım Süresi',
                      deger: '$_yilSayisi yıl',
                    ),
                    Slider(
                      value: _yilSayisi.toDouble(),
                      min: 1, max: 50, divisions: 49,
                      onChanged: (v) => setState(() => _yilSayisi = v.toInt()),
                    ),
                  ]),
                )),

                const SizedBox(height: 16),

                // Sonuç Kartı
                _AppCard(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    const Text('Gelecek Değer',
                        style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
                    const SizedBox(height: 6),
                    Text(
                      TLFormatter.format(_gelecekDeger),
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF30D158)),
                    ),
                    const Divider(height: 24),
                    Row(children: [
                      Expanded(child: _SonucSatir(
                          baslik: 'Toplam Yatırım',
                          deger: TLFormatter.compact(_toplamYatirim),
                          renk: Colors.black)),
                      const VerticalDivider(width: 1),
                      Expanded(child: _SonucSatir(
                          baslik: 'Faiz Getirisi',
                          deger: TLFormatter.compact(_toplamGetiri),
                          renk: const Color(0xFF30D158))),
                      const VerticalDivider(width: 1),
                      Expanded(child: _SonucSatir(
                          baslik: 'Büyüme',
                          deger: '%${_buyumeOrani.toInt()}',
                          renk: const Color(0xFFFF9500))),
                    ]),
                  ]),
                )),

                const SizedBox(height: 16),

                // Grafik Kartı
                _AppCard(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Büyüme Grafiği',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: _buildChart(),
                      ),
                      const SizedBox(height: 12),
                      Row(children: const [
                        _LejantDot(renk: Color(0xFF30D158), etiket: 'Toplam Değer'),
                        SizedBox(width: 20),
                        _LejantDot(renk: Color(0xFFAEAEB2), etiket: 'Yatırılan', dashed: true),
                      ]),
                    ],
                  ),
                )),

                const SizedBox(height: 16),

                // Kilometre Taşları
                _AppCard(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kilometre Taşları',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      ..._kilometre.map((tas) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _KilometreSatir(tas: tas),
                      )),
                    ],
                  ),
                )),

                const SizedBox(height: 16),
                const Text(
                  'Bu hesaplamalar yalnızca eğitim amaçlıdır. Yatırım tavsiyesi değildir.',
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

  Widget _buildChart() {
    final veriler = _grafikVerileri;
    if (veriler.isEmpty) return const SizedBox();

    final maxY = veriler.last.toplam * 1.1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: _yilSayisi.toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFFF0F0F0),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: maxY / 4,
              getTitlesWidget: (v, _) => Text(
                TLFormatter.compact(v),
                style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93)),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (_yilSayisi / 5).ceilToDouble(),
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}y',
                style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93)),
              ),
            ),
          ),
        ),
        lineBarsData: [
          // Toplam değer çizgisi
          LineChartBarData(
            spots: veriler
                .map((p) => FlSpot(p.yil.toDouble(), p.toplam))
                .toList(),
            color: const Color(0xFF30D158),
            barWidth: 2.5,
            isCurved: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF30D158).withOpacity(0.3),
                  const Color(0xFF30D158).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Yatırılan tutar çizgisi
          LineChartBarData(
            spots: veriler
                .map((p) => FlSpot(p.yil.toDouble(), p.yatirim))
                .toList(),
            color: const Color(0xFFAEAEB2),
            barWidth: 1.5,
            isCurved: false,
            dashArray: [4, 4],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String baslik;
  final double deger;
  final double min, max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.baslik,
    required this.deger,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _LabelRow(baslik: baslik, deger: label),
      Slider(value: deger, min: min, max: max, divisions: divisions, onChanged: onChanged),
    ]);
  }
}

class _LabelRow extends StatelessWidget {
  final String baslik;
  final String deger;
  const _LabelRow({required this.baslik, required this.deger});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Text(deger,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF30D158))),
      ],
    );
  }
}

class _SonucSatir extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color renk;
  const _SonucSatir({required this.baslik, required this.deger, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(deger,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: renk)),
      const SizedBox(height: 2),
      Text(baslik,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
          textAlign: TextAlign.center),
    ]);
  }
}

class _LejantDot extends StatelessWidget {
  final Color renk;
  final String etiket;
  final bool dashed;
  const _LejantDot({required this.renk, required this.etiket, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 18, height: 3, color: renk),
      const SizedBox(width: 6),
      Text(etiket, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
    ]);
  }
}

class _KilometreSatir extends StatelessWidget {
  final KilometreTasi tas;
  const _KilometreSatir({required this.tas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(
          tas.ulasildi ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: tas.ulasildi ? const Color(0xFF30D158) : const Color(0xFF8E8E93),
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tas.etiket,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Text(TLFormatter.format(tas.tutar),
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
        ])),
        if (tas.ulasilanYil != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8FBF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${tas.ulasilanYil}. yıl',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF30D158))),
          )
        else
          const Text('Ulaşılamıyor',
              style: TextStyle(fontSize: 12, color: Color(0xFFC7C7CC))),
      ]),
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
