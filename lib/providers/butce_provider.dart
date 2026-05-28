import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../db/database_helper.dart';

class ButceProvider extends ChangeNotifier {
  List<Gider> giderler = [];
  double aylikGelir = 0;

  ButceProvider() {
    yukle();
  }

  Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    aylikGelir = prefs.getDouble('aylik_gelir') ?? 0;
    giderler = await DatabaseHelper.instance.giderleriGetir();
    notifyListeners();
  }

  Future<void> gelirGuncelle(double yeniGelir) async {
    aylikGelir = yeniGelir;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('aylik_gelir', yeniGelir);
    notifyListeners();
  }

  double get toplamGider => giderler.fold(0, (s, g) => s + g.tutar);

  double get aylikTasarruf => (aylikGelir - toplamGider).clamp(0, double.infinity);

  double get tasarrufOrani =>
      aylikGelir > 0 ? (aylikTasarruf / aylikGelir) * 100 : 0;

  double get yillikTasarruf => aylikTasarruf * 12;

  String get tasarrufMesaji {
    final oran = tasarrufOrani;
    if (aylikGelir == 0) return 'Aylık gelirinizi girin ve başlayın.';
    if (oran >= 30) return 'Harika! Gelirinizin %${oran.toInt()}\'ini biriktiriyorsunuz 🚀';
    if (oran >= 20) return 'İyi gidiyorsunuz! Hedef %30\'un üzeri.';
    if (oran >= 10) return 'Güzel başlangıç. Giderlerinizi azaltmayı deneyin.';
    return 'Tasarruf oranınızı artırma zamanı!';
  }

  Future<void> giderEkle({
    required String ad,
    required double tutar,
    required GiderKategori kategori,
  }) async {
    final g = Gider(ad: ad, tutar: tutar, kategori: kategori);
    await DatabaseHelper.instance.giderEkle(g);
    await yukle();
  }

  Future<void> giderGuncelle(Gider g) async {
    await DatabaseHelper.instance.giderGuncelle(g);
    await yukle();
  }

  Future<void> giderSil(int id) async {
    await DatabaseHelper.instance.giderSil(id);
    await yukle();
  }

  Future<void> tumVerileriSil() async {
    await DatabaseHelper.instance.tumVerileriSil();
    await gelirGuncelle(0);
    await yukle();
  }
}
