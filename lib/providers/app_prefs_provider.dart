import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/notifications.dart';

class AppPrefsProvider extends ChangeNotifier {
  double hedefTutar = 0;
  String hedefAdi = 'Mali Hedef';
  bool bildirimAktif = false;
  int bildirimSaati = 9;

  AppPrefsProvider() {
    _yukle();
  }

  Future<void> _yukle() async {
    final prefs = await SharedPreferences.getInstance();
    hedefTutar = prefs.getDouble('hedef_tutar') ?? 0;
    final ad = prefs.getString('hedef_ad') ?? '';
    hedefAdi = ad.isEmpty ? 'Mali Hedef' : ad;
    bildirimAktif = prefs.getBool('bildirim_aktif') ?? false;
    bildirimSaati = prefs.getInt('bildirim_saati') ?? 9;
    notifyListeners();
  }

  /// Hedefe kaydet. Başarılı olursa true döner.
  Future<void> hedefKaydet({required String ad, required double tutar}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hedef_ad', ad);
    await prefs.setDouble('hedef_tutar', tutar);
    hedefAdi = ad.isEmpty ? 'Mali Hedef' : ad;
    hedefTutar = tutar;
    notifyListeners();
  }

  /// Bildirimi aç/kapat. İzin verilmezse false döner.
  Future<bool> bildirimToggle(bool aktif) async {
    if (aktif) {
      final izin = await NotificationManager.shared.izinIste();
      if (!izin) return false;
      await NotificationManager.shared.gunlukBildirimAyarla(bildirimSaati);
    } else {
      await NotificationManager.shared.bildirimleriIptalEt();
    }
    bildirimAktif = aktif;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bildirim_aktif', aktif);
    notifyListeners();
    return true;
  }

  /// Bildirim saatini güncelle.
  Future<void> bildirimSaatiGuncelle(int saat) async {
    bildirimSaati = saat;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bildirim_saati', saat);
    if (bildirimAktif) {
      await NotificationManager.shared.gunlukBildirimAyarla(saat);
    }
    notifyListeners();
  }

  /// Hedef verilerini sıfırla (tüm verileri sil sonrası).
  Future<void> sifirla() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hedef_tutar');
    await prefs.remove('hedef_ad');
    hedefTutar = 0;
    hedefAdi = 'Mali Hedef';
    notifyListeners();
  }
}
