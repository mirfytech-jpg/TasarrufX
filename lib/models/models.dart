import 'package:flutter/material.dart';

// ─── Varlık Kategorisi ───────────────────────────────────────────────────────

enum VarlikKategori {
  nakit,
  kripto,
  hisse,
  altin,
  gayrimenkul,
  arac,
  diger;

  String get ad {
    switch (this) {
      case VarlikKategori.nakit:        return 'Nakit';
      case VarlikKategori.kripto:       return 'Kripto';
      case VarlikKategori.hisse:        return 'Hisse Senedi';
      case VarlikKategori.altin:        return 'Altın & Gümüş';
      case VarlikKategori.gayrimenkul:  return 'Gayrimenkul';
      case VarlikKategori.arac:         return 'Araç';
      case VarlikKategori.diger:        return 'Diğer';
    }
  }

  IconData get ikon {
    switch (this) {
      case VarlikKategori.nakit:        return Icons.payments_rounded;
      case VarlikKategori.kripto:       return Icons.currency_bitcoin_rounded;
      case VarlikKategori.hisse:        return Icons.bar_chart_rounded;
      case VarlikKategori.altin:        return Icons.star_rounded;
      case VarlikKategori.gayrimenkul:  return Icons.home_rounded;
      case VarlikKategori.arac:         return Icons.directions_car_rounded;
      case VarlikKategori.diger:        return Icons.more_horiz_rounded;
    }
  }

  Color get renk {
    switch (this) {
      case VarlikKategori.nakit:        return const Color(0xFF34C759);
      case VarlikKategori.kripto:       return const Color(0xFFF7981D);
      case VarlikKategori.hisse:        return const Color(0xFF3B82F6);
      case VarlikKategori.altin:        return const Color(0xFFEFCC1A);
      case VarlikKategori.gayrimenkul:  return const Color(0xFF9B59B6);
      case VarlikKategori.arac:         return const Color(0xFFE74C3C);
      case VarlikKategori.diger:        return const Color(0xFF8E8E93);
    }
  }

  static VarlikKategori fromString(String s) {
    return VarlikKategori.values.firstWhere(
      (e) => e.ad == s,
      orElse: () => VarlikKategori.diger,
    );
  }
}

// ─── Gider Kategorisi ─────────────────────────────────────────────────────────

enum GiderKategori {
  konut,
  yiyecek,
  ulasim,
  faturalar,
  eglence,
  saglik,
  egitim,
  diger;

  String get ad {
    switch (this) {
      case GiderKategori.konut:     return 'Konut';
      case GiderKategori.yiyecek:   return 'Yiyecek';
      case GiderKategori.ulasim:    return 'Ulaşım';
      case GiderKategori.faturalar: return 'Faturalar';
      case GiderKategori.eglence:   return 'Eğlence';
      case GiderKategori.saglik:    return 'Sağlık';
      case GiderKategori.egitim:    return 'Eğitim';
      case GiderKategori.diger:     return 'Diğer';
    }
  }

  IconData get ikon {
    switch (this) {
      case GiderKategori.konut:     return Icons.home_rounded;
      case GiderKategori.yiyecek:   return Icons.restaurant_rounded;
      case GiderKategori.ulasim:    return Icons.directions_car_rounded;
      case GiderKategori.faturalar: return Icons.bolt_rounded;
      case GiderKategori.eglence:   return Icons.tv_rounded;
      case GiderKategori.saglik:    return Icons.favorite_rounded;
      case GiderKategori.egitim:    return Icons.menu_book_rounded;
      case GiderKategori.diger:     return Icons.more_horiz_rounded;
    }
  }

  static GiderKategori fromString(String s) {
    return GiderKategori.values.firstWhere(
      (e) => e.ad == s,
      orElse: () => GiderKategori.diger,
    );
  }
}

// ─── Varlık Modeli ────────────────────────────────────────────────────────────

class Varlik {
  final int? id;
  final String ad;
  final VarlikKategori kategori;
  final double deger;
  final String? not;
  final DateTime eklenmeTarihi;

  Varlik({
    this.id,
    required this.ad,
    required this.kategori,
    required this.deger,
    this.not,
    DateTime? eklenmeTarihi,
  }) : eklenmeTarihi = eklenmeTarihi ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ad': ad,
    'kategori': kategori.ad,
    'deger': deger,
    'not': not,
    'eklenmeTarihi': eklenmeTarihi.toIso8601String(),
  };

  factory Varlik.fromMap(Map<String, dynamic> m) => Varlik(
    id: m['id'] as int?,
    ad: m['ad'] as String,
    kategori: VarlikKategori.fromString(m['kategori'] as String),
    deger: m['deger'] as double,
    not: m['not'] as String?,
    eklenmeTarihi: DateTime.parse(m['eklenmeTarihi'] as String),
  );
}

// ─── Gider Modeli ─────────────────────────────────────────────────────────────

class Gider {
  final int? id;
  final String ad;
  final double tutar;
  final GiderKategori kategori;

  Gider({
    this.id,
    required this.ad,
    required this.tutar,
    required this.kategori,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ad': ad,
    'tutar': tutar,
    'kategori': kategori.ad,
  };

  factory Gider.fromMap(Map<String, dynamic> m) => Gider(
    id: m['id'] as int?,
    ad: m['ad'] as String,
    tutar: m['tutar'] as double,
    kategori: GiderKategori.fromString(m['kategori'] as String),
  );
}

// ─── Alıntı Modeli ────────────────────────────────────────────────────────────

class AlintıModel {
  final int id;
  final String metin;
  final String yazar;

  AlintıModel({required this.id, required this.metin, required this.yazar});

  factory AlintıModel.fromJson(Map<String, dynamic> j) => AlintıModel(
    id: j['id'] as int,
    metin: j['metin'] as String,
    yazar: j['yazar'] as String,
  );
}

// ─── Büyüme Veri Noktası ─────────────────────────────────────────────────────

class BuyumeNoktasi {
  final int yil;
  final double toplam;
  final double yatirim;

  BuyumeNoktasi({required this.yil, required this.toplam, required this.yatirim});

  double get getiri => toplam - yatirim;
}

// ─── Kilometre Taşı ──────────────────────────────────────────────────────────

class KilometreTasi {
  final String etiket;
  final double tutar;
  final int? ulasılanYil;

  KilometreTasi({required this.etiket, required this.tutar, this.ulasılanYil});

  bool get ulasildi => ulasılanYil != null;
}
