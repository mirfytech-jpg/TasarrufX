import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/varlik_provider.dart';
import '../providers/butce_provider.dart';
import '../providers/app_prefs_provider.dart';

class AyarlarScreen extends StatefulWidget {
  const AyarlarScreen({super.key});

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  final _hedefAdCtrl = TextEditingController();
  final _hedefTutarCtrl = TextEditingController();
  bool _textlerYuklendi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _textleriYukle());
  }

  @override
  void dispose() {
    _hedefAdCtrl.dispose();
    _hedefTutarCtrl.dispose();
    super.dispose();
  }

  /// Metin alanlarını AppPrefsProvider'dan bir kez doldur.
  void _textleriYukle() {
    if (!mounted || _textlerYuklendi) return;
    _textlerYuklendi = true;
    final prefs = context.read<AppPrefsProvider>();
    final ad = prefs.hedefAdi == 'Mali Hedef' ? '' : prefs.hedefAdi;
    _hedefAdCtrl.text = ad;
    _hedefTutarCtrl.text =
        prefs.hedefTutar > 0 ? prefs.hedefTutar.toStringAsFixed(0) : '';
  }

  Future<void> _hedefKaydet() async {
    final ad = _hedefAdCtrl.text.trim();
    final tutar = double.tryParse(_hedefTutarCtrl.text) ?? 0;
    await context.read<AppPrefsProvider>().hedefKaydet(ad: ad, tutar: tutar);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hedef kaydedildi ✓')),
    );
  }

  Future<void> _bildirimToggle(bool aktif) async {
    final ok =
        await context.read<AppPrefsProvider>().bildirimToggle(aktif);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bildirim izni verilmedi.')),
      );
    }
  }

  Future<void> _saatDegistir(int saat) async {
    await context.read<AppPrefsProvider>().bildirimSaatiGuncelle(saat);
  }

  Future<void> _tumVerileriSil() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text(
            'Tüm varlık, gider ve hedef verileri kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (onay != true) return;
    if (!mounted) return;

    await context.read<ButceProvider>().tumVerileriSil();
    if (!mounted) return;
    await context.read<VarlikProvider>().yukle();
    if (!mounted) return;
    await context.read<AppPrefsProvider>().sifirla();
    if (!mounted) return;

    setState(() {
      _textlerYuklendi = false;
      _hedefAdCtrl.clear();
      _hedefTutarCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm veriler silindi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appPrefs = context.watch<AppPrefsProvider>();
    final bildirimAktif = appPrefs.bildirimAktif;
    final bildirimSaati = appPrefs.bildirimSaati;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Ayarlar'),
            floating: true,
            backgroundColor: Color(0xFFF2F2F7),
          ),
          SliverList(
            delegate: SliverChildListDelegate([

              // ─── Mali Hedef ─────────────────────────────────────────────
              _SectionHeader(baslik: 'Mali Hedef'),
              _SectionCard(children: [
                _SettingsTile(
                  ikon: Icons.flag_rounded,
                  child: TextField(
                    controller: _hedefAdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Hedef adı (örn: Ev almak)',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  ikon: Icons.track_changes_rounded,
                  child: Row(children: [
                    const Text('₺',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF30D158))),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _hedefTutarCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Hedef tutar',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ]),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ElevatedButton(
                  onPressed: _hedefKaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF30D158),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Kaydet',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hedef, Ana Sayfa\'daki ilerleme çubuğunda gösterilir.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                ),
              ),

              // ─── Bildirimler ────────────────────────────────────────────
              _SectionHeader(baslik: 'Bildirimler'),
              _SectionCard(children: [
                _SettingsTile(
                  ikon: Icons.notifications_rounded,
                  child: Row(children: [
                    const Expanded(child: Text('Günlük Motivasyon',
                        style: TextStyle(fontSize: 15))),
                    Switch(value: bildirimAktif, onChanged: _bildirimToggle),
                  ]),
                ),
                if (bildirimAktif) ...[
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    ikon: Icons.access_time_rounded,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bildirim Saati',
                            style: TextStyle(fontSize: 15)),
                        Row(children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            onPressed: bildirimSaati > 6
                                ? () => _saatDegistir(bildirimSaati - 1)
                                : null,
                          ),
                          Text('$bildirimSaati:00',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            onPressed: bildirimSaati < 22
                                ? () => _saatDegistir(bildirimSaati + 1)
                                : null,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ]),

              // ─── Uygulama ───────────────────────────────────────────────
              _SectionHeader(baslik: 'Uygulama'),
              _SectionCard(children: [
                _SettingsTile(
                  ikon: Icons.info_rounded,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sürüm', style: TextStyle(fontSize: 15)),
                      Text('1.0.0', style: TextStyle(
                          fontSize: 15, color: Color(0xFF8E8E93))),
                    ],
                  ),
                ),
              ]),

              // ─── Yasal Uyarı ────────────────────────────────────────────
              _SectionHeader(baslik: 'Hukuki'),
              _SectionCard(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.shield_rounded, color: Color(0xFFFF9500), size: 18),
                        SizedBox(width: 8),
                        Text('Yasal Uyarı',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 8),
                      const Text(
                        'Bu uygulama yatırım tavsiyesi vermez ve finansal danışmanlık '
                        'hizmeti sunmaz. Gösterilen hesaplamalar yalnızca eğitim ve bilgi '
                        'amaçlıdır. Herhangi bir yatırım kararı vermeden önce lisanslı bir '
                        'finansal danışmana başvurunuz. Uygulama herhangi bir veri toplamaz; '
                        'tüm bilgiler yalnızca cihazınızda saklanır.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93), height: 1.5),
                      ),
                    ],
                  ),
                ),
              ]),

              // ─── Veri Yönetimi ──────────────────────────────────────────
              _SectionHeader(baslik: 'Veri'),
              _SectionCard(children: [
                ListTile(
                  onTap: _tumVerileriSil,
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Tüm Verileri Sil',
                      style: TextStyle(color: Colors.red, fontSize: 15)),
                ),
              ]),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Bu işlem geri alınamaz. Tüm varlık, gider ve hedef verileri silinir.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                ),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String baslik;
  const _SectionHeader({required this.baslik});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(baslik.toUpperCase(),
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData ikon;
  final Widget child;
  const _SettingsTile({required this.ikon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Icon(ikon, color: const Color(0xFF30D158), size: 22),
        const SizedBox(width: 12),
        Expanded(child: child),
      ]),
    );
  }
}
