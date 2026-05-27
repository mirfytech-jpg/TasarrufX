# TasarrufX — Xcode Kurulum Rehberi

## 1. Xcode Projesi Oluştur

1. Xcode'u aç → **Create New Project**
2. **iOS → App** seç → **Next**
3. Bilgileri gir:
   - Product Name: `TasarrufX`
   - Team: (Apple geliştirici hesabın)
   - Bundle Identifier: `com.senin.TasarrufX`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** ← (Core Data'yı biz kod ile kuruyoruz)
4. Masaüstündeki **TasarrufX** klasörüne kaydet

---

## 2. Varsayılan Dosyaları Sil

Xcode'un oluşturduğu bu dosyaları sil:
- `ContentView.swift` → Sil (bizimkiyle değiştireceğiz)
- `TasarrufXApp.swift` → Sil (bizimkiyle değiştireceğiz)

---

## 3. Kaynak Dosyaları Ekle

Sol panelde proje klasörüne **sağ tık → Add Files to "TasarrufX"** ile şu klasörleri ekle:

```
TasarrufX/
├── TasarrufXApp.swift         ← Kök
├── ContentView.swift               ← Kök
├── Core/
│   ├── PersistenceController.swift
│   └── NotificationManager.swift
├── Models/
│   └── AppModels.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── SimulatorViewModel.swift
│   ├── VarlikViewModel.swift
│   └── BütçeViewModel.swift
├── Views/
│   ├── Components/
│   │   ├── DesignSystem.swift
│   │   └── SharedComponents.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Simulator/
│   │   └── SimulatorView.swift
│   ├── Assets/
│   │   ├── VarlikView.swift
│   │   └── VarlikEkleSheet.swift
│   ├── Budget/
│   │   ├── BütçeView.swift
│   │   └── GiderEkleSheet.swift
│   └── Settings/
│       └── AyarlarView.swift
└── Resources/
    └── alintilar.json
```

> **İpucu:** Dosyaları eklerken "Copy items if needed" ve "Create groups" seçili olsun.

---

## 4. alintilar.json Dosyasını Bundle'a Ekle

1. `alintilar.json` dosyasını projeye ekledikten sonra sol panelde seç
2. Sağdaki **File Inspector → Target Membership** → `TasarrufX` kutusunu işaretle
3. Build Phases → **Copy Bundle Resources** içinde göründüğünü kontrol et

---

## 5. Deployment Target

1. Sol panelde proje adına tıkla
2. **Targets → TasarrufX → General → Minimum Deployments**
3. **iOS 17.0** seç (Swift Charts SectorMark için gerekli)

---

## 6. Capabilities

1. **Signing & Capabilities** sekmesi
2. **+ Capability** → **Push Notifications** EKLEME (local notification kullanıyoruz)
3. Sadece **Background Modes** gerekmiyor, uygulama tamamen offline çalışır

---

## 7. AdMob Entegrasyonu (İsteğe Bağlı)

```bash
# Podfile'a ekle:
pod 'Google-Mobile-Ads-SDK'
```

Veya Swift Package Manager ile:
- URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
- Sonra `AppDelegate` oluşturup `GADMobileAds.sharedInstance().start()` çağır

---

## 8. Build & Run

- Simülatör veya gerçek cihaz seç
- `Cmd + R` ile çalıştır
- İlk açılışta onboarding ekranı gelir, "Başla" deyince ana sayfa açılır

---

## Özellikler

| Özellik | Durum |
|--------|-------|
| Bileşik faiz simülatörü | ✅ |
| Varlık takibi (6 kategori) | ✅ |
| Bütçe & tasarruf hesabı | ✅ |
| Pasta grafik (donut) | ✅ |
| Büyüme çizgi grafiği | ✅ |
| Kilometre taşları | ✅ |
| Günlük motivasyon bildirimi | ✅ |
| 30 Türkçe finansal alıntı | ✅ |
| Onboarding (3 sayfa) | ✅ |
| Core Data (offline) | ✅ |
| Yasal uyarı | ✅ |
| Karanlık mod desteği | ✅ (sistem temasına uyumlu) |

---

## Mimari

```
MVVM
├── View        → Yalnızca SwiftUI görünümleri
├── ViewModel   → ObservableObject, Core Data sorguları
└── Model       → NSManagedObject alt sınıfları, enum'lar
```

Veri akışı: `Core Data ← ViewModel → View`

---

> **Not:** Bu uygulama yatırım tavsiyesi vermez. Tüm hesaplamalar eğitim amaçlıdır.
