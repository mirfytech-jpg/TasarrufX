import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../db/database_helper.dart';

class VarlikProvider extends ChangeNotifier {
  List<Varlik> varliklar = [];

  VarlikProvider() {
    yukle();
  }

  Future<void> yukle() async {
    varliklar = await DatabaseHelper.instance.varliklarGetir();
    notifyListeners();
  }

  double get toplamDeger => varliklar.fold(0, (s, v) => s + v.deger);

  Map<VarlikKategori, List<Varlik>> get grupluVarliklar =>
      Map.fromEntries(VarlikKategori.values.map((k) {
        final liste = varliklar.where((v) => v.kategori == k).toList();
        return MapEntry(k, liste);
      }));

  List<({VarlikKategori kategori, double deger})> get kategoriToplamları {
    final sozluk = <VarlikKategori, double>{};
    for (final v in varliklar) {
      sozluk[v.kategori] = (sozluk[v.kategori] ?? 0) + v.deger;
    }
    return sozluk.entries
        .map((e) => (kategori: e.key, deger: e.value))
        .toList()
      ..sort((a, b) => b.deger.compareTo(a.deger));
  }

  Future<void> ekle({
    required String ad,
    required VarlikKategori kategori,
    required double deger,
    String? not,
  }) async {
    final v = Varlik(ad: ad, kategori: kategori, deger: deger, not: not);
    await DatabaseHelper.instance.varlikEkle(v);
    await yukle();
  }

  Future<void> guncelle(Varlik v) async {
    await DatabaseHelper.instance.varlikGuncelle(v);
    await yukle();
  }

  Future<void> sil(int id) async {
    await DatabaseHelper.instance.varlikSil(id);
    await yukle();
  }
}
