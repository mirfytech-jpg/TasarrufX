import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../providers/varlik_provider.dart';
import '../utils/formatters.dart';

class VarlikScreen extends StatefulWidget {
  const VarlikScreen({super.key});

  @override
  State<VarlikScreen> createState() => _VarlikScreenState();
}

class _VarlikScreenState extends State<VarlikScreen> {
  void _ekleSheet({Varlik? duzenle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VarlikSheet(duzenle: duzenle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VarlikProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Varlıklarım'),
            floating: true,
            backgroundColor: const Color(0xFFF2F2F7),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, size: 28),
                onPressed: () => _ekleSheet(),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Pasta Grafik
                _AppCard(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: vm.toplamDeger == 0
                      ? const _BosEkran(
                          ikon: Icons.work_rounded,
                          baslik: 'Henüz Varlık Yok',
                          aciklama: 'İlk varlığını eklemek için + butonuna dokun.',
                        )
                      : Column(children: [
                          SizedBox(
                            height: 180,
                            child: PieChart(PieChartData(
                              sections: vm.kategoriToplamları
                                  .map((k) => PieChartSectionData(
                                        value: k.deger,
                                        color: k.kategori.renk,
                                        title: vm.toplamDeger > 0
                                            ? '%${(k.deger / vm.toplamDeger * 100).toInt()}'
                                            : '',
                                        titleStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                        radius: 70,
                                      ))
                                  .toList(),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            )),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: vm.kategoriToplamları
                                .map((k) => Row(mainAxisSize: MainAxisSize.min, children: [
                                      Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: k.kategori.renk,
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 4),
                                      Text(k.kategori.ad,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF8E8E93))),
                                    ]))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toplam: ${TLFormatter.format(vm.toplamDeger)}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF30D158)),
                          ),
                        ]),
                )),

                const SizedBox(height: 16),

                // Varlık Listesi
                if (vm.varliklar.isNotEmpty)
                  ...VarlikKategori.values.map((kat) {
                    final liste = vm.grupluVarliklar[kat] ?? [];
                    if (liste.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _KategoriBlok(
                        kategori: kat,
                        varliklar: liste,
                        onDuzenle: (v) => _ekleSheet(duzenle: v),
                        onSil: (v) => vm.sil(v.id!),
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _KategoriBlok extends StatelessWidget {
  final VarlikKategori kategori;
  final List<Varlik> varliklar;
  final void Function(Varlik) onDuzenle;
  final void Function(Varlik) onSil;

  const _KategoriBlok({
    required this.kategori,
    required this.varliklar,
    required this.onDuzenle,
    required this.onSil,
  });

  @override
  Widget build(BuildContext context) {
    final toplam = varliklar.fold(0.0, (s, v) => s + v.deger);
    return _AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            Icon(kategori.ikon, color: kategori.renk, size: 18),
            const SizedBox(width: 8),
            Text(kategori.ad,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(TLFormatter.compact(toplam),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kategori.renk)),
          ]),
        ),
        const Divider(height: 20, indent: 16, endIndent: 16),
        ...varliklar.asMap().entries.map((entry) {
          final v = entry.value;
          final isLast = entry.key == varliklar.length - 1;
          return Column(children: [
            Dismissible(
              key: ValueKey(v.id),
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
                    title: const Text('Varlığı Sil'),
                    content: const Text('Bu varlığı silmek istiyor musunuz?'),
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
              onDismissed: (_) => onSil(v),
              child: ListTile(
                onTap: () => onDuzenle(v),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: kategori.renk.withOpacity(0.15),
                  child: Icon(kategori.ikon, color: kategori.renk, size: 18),
                ),
                title: Text(v.ad,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                subtitle: v.not != null && v.not!.isNotEmpty
                    ? Text(v.not!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12))
                    : null,
                trailing: Text(TLFormatter.format(v.deger),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            if (!isLast) const Divider(height: 1, indent: 70),
          ]);
        }),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ─── Varlık Ekleme Sheet ─────────────────────────────────────────────────────

class _VarlikSheet extends StatefulWidget {
  final Varlik? duzenle;
  const _VarlikSheet({this.duzenle});

  @override
  State<_VarlikSheet> createState() => _VarlikSheetState();
}

class _VarlikSheetState extends State<_VarlikSheet> {
  late final TextEditingController _adCtrl;
  late final TextEditingController _degerCtrl;
  late final TextEditingController _notCtrl;
  late VarlikKategori _kategori;

  @override
  void initState() {
    super.initState();
    final v = widget.duzenle;
    _adCtrl = TextEditingController(text: v?.ad ?? '');
    _degerCtrl = TextEditingController(
        text: v != null ? v.deger.toStringAsFixed(0) : '');
    _notCtrl = TextEditingController(text: v?.not ?? '');
    _kategori = v?.kategori ?? VarlikKategori.nakit;
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _degerCtrl.dispose();
    _notCtrl.dispose();
    super.dispose();
  }

  void _kaydet() {
    final ad = _adCtrl.text.trim();
    final deger = double.tryParse(_degerCtrl.text) ?? 0;
    if (ad.isEmpty || deger <= 0) return;

    final vm = context.read<VarlikProvider>();
    if (widget.duzenle != null) {
      vm.guncelle(Varlik(
        id: widget.duzenle!.id,
        ad: ad,
        kategori: _kategori,
        deger: deger,
        not: _notCtrl.text.trim().isEmpty ? null : _notCtrl.text.trim(),
        eklenmeTarihi: widget.duzenle!.eklenmeTarihi,
      ));
    } else {
      vm.ekle(
        ad: ad,
        kategori: _kategori,
        deger: deger,
        not: _notCtrl.text.trim().isEmpty ? null : _notCtrl.text.trim(),
      );
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
            Text(widget.duzenle != null ? 'Varlığı Düzenle' : 'Varlık Ekle',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            // Kategori
            DropdownButtonFormField<VarlikKategori>(
              value: _kategori,
              decoration: _inputDecor('Kategori'),
              items: VarlikKategori.values
                  .map((k) => DropdownMenuItem(value: k, child: Text(k.ad)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 12),

            TextField(controller: _adCtrl,
                decoration: _inputDecor('Varlık Adı (örn: Ziraat Bankası)')),
            const SizedBox(height: 12),

            TextField(
              controller: _degerCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecor('Değer (₺)'),
            ),
            const SizedBox(height: 12),

            TextField(controller: _notCtrl,
                decoration: _inputDecor('Not (opsiyonel)')),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E5EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF30D158), width: 2),
    ),
  );
}

// ─── Ortak Widgetlar ──────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(children: [
        Icon(ikon, size: 44, color: const Color(0xFFD1D1D6)),
        const SizedBox(height: 12),
        Text(baslik,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
        const SizedBox(height: 6),
        Text(aciklama,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFFAEAEB2))),
      ]),
    );
  }
}
