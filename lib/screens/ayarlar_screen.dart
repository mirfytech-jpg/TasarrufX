import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/varlik_provider.dart';
import '../providers/butce_provider.dart';
import '../utils/notifications.dart';

class AyarlarScreen extends StatefulWidget {
  const AyarlarScreen({super.key});

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  final _hedefAdCtrl = TextEditingController();
  final _hedefTutarCtrl = TextEditingController();
  bool _bildirimAktif = false;
  int _bildirimSaati = 9;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _hedefAdCtrl.dispose();
    _hedefTutarCtrl.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hedefAdCtrl.text = prefs.getString('hedef_ad') ?? '';
      final tutar = prefs.getDouble('hedef_tutar') ?? 0;
      _hedefTutarCtrl.text = tutar > 0 ? tutar.toStringAsFixed(0) : '';
      _bildirimAktif = prefs.getBool('bildirim_aktif') ?? false;
      _bildirimSaati = prefs.getInt('bildirim_saati') ?? 9;
    });
  }

  Future<void> _hedefKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hedef_ad', _hedefAdCtrl.text.trim());
    final tutar = double.tryParse(_hedefTutarCtrl.text) ?? 0;
    await prefs.setDouble('hedef_tutar', tutar);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedef kaydedildi ✓')),
      );
    }
  }

  Future<void> _bildirimToggle(bool aktif) async {
    final prefs = await SharedPreferences.getInstance();
    if (aktif) {
      final izin = await NotificationManager.shared.izinIste();
      if (!izin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bildirim izni verilmedi.')),
          );
        }
        return;
      }
      await NotificationManager.shared.gunlukBildirimAyarla(_bildirimSaati);
    } else {
      await NotificationManager.shared.bildirimleriIptalEt();
    }
    setState(() => _bildirimAktif = aktif);
    await prefs.setBool('bildirim_aktif', aktif);
  }

  Future<void> _saatDegistir(int saat) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _bildirimSaati = saat);
    await prefs.setInt('bildirim_saati', saat);
    if (_bildirimAktif) {
      await NotificationManager.shared.gunlukBildirimAyarla(saat);
    }
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

    final prefs = await SharedPreferences.getInstance();
    await context.read<ButceProvider>().tumVerileriSil();
    await context.read<VarlikProvider>().yukle();
    await prefs.remove('hedef_tutar');
    await prefs.remove('hedef_ad');

    setState(() {
      _hedefAdCtrl.clear();
      _hedefTutarCtrl.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm veriler silindi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Switch(value: _bildirimAktif, onChanged: _bildirimToggle),
                  ]),
                ),
                if (_bildirimAktif) ...[
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
                            onPressed: _bildirimSaati > 6
                                ? () => _saatDegistir(_bildirimSaati - 1)
                                : null,
                          ),
                          Text('$_bildirimSaati:00',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            onPressed: _bildirimSaati < 22
                                ? () => _saatDegistir(_bildirimSaati + 1)
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
