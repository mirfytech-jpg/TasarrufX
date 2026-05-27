# Codemagic ile App Store'a Yayın Rehberi
## (Mac'siz, tamamen cloud üzerinden)

---

## 📋 Önce Neye İhtiyacın Var?

| Gereksinim | Maliyet | Nereden |
|-----------|---------|---------|
| Apple Developer hesabı | 99 USD/yıl | developer.apple.com |
| Codemagic hesabı | Aylık 500 build dakikası ücretsiz | codemagic.io |
| GitHub hesabı | Ücretsiz | github.com |

---

## ADIM 1 — Bundle ID Seç (2 dakika)

`project.yml` ve `codemagic.yaml` dosyalarında `com.DEGISTIR` yazan 3 yeri kendi Bundle ID'nle değiştir.

**Örnek:** `com.seninadiniz.bilesikbuyume`

Kuralllar:
- Sadece küçük harf, nokta, harf
- App Store'da benzersiz olmalı
- Sonradan değiştirilemez!

---

## ADIM 2 — App Icon Ekle (5 dakika)

`Assets.xcassets/AppIcon.appiconset/` klasörüne **AppIcon-1024.png** ekle.

**Hızlı ikon yap:** canva.com → "App Icon" template → 1024x1024 PNG indir → klasöre koy

---

## ADIM 3 — GitHub'a Yükle (5 dakika)

```bash
# GitHub'da "TasarrufX" adında yeni repo oluştur (private önerilir)
# Sonra:
git init
git add .
git commit -m "İlk commit"
git branch -M main
git remote add origin https://github.com/KULLANICIN/TasarrufX.git
git push -u origin main
```

---

## ADIM 4 — Apple Developer Hesabı Ayarları (15 dakika)

### 4a. App Store Connect'te Uygulama Oluştur
1. appstoreconnect.apple.com → **Uygulamalarım → +**
2. Platform: **iOS**
3. Ad: **TasarrufX**
4. Bundle ID: az önce seçtiğin ID
5. SKU: `bilesikbuyume2024` (istediğin bir kod)
6. Oluştur → **Apple ID notunu al** (sonra lazım)

### 4b. App Store Connect API Anahtarı Oluştur
1. appstoreconnect.apple.com → Kullanıcılar → **Anahtarlar**
2. **+** → Ad: `Codemagic` → Rol: **App Manager**
3. **İndir** (sadece bir kere indirebilirsin! `.p8` dosyası)
4. Şunları not al:
   - **Key ID** (10 karakter)
   - **Issuer ID** (UUID formatında)
   - **.p8 dosyası** içeriği

---

## ADIM 5 — Codemagic Kurulumu (10 dakika)

### 5a. Hesap Aç
1. codemagic.io → **Sign up with GitHub**
2. GitHub repoyu seç

### 5b. Uygulama Ekle
1. **Add application → GitHub → TasarrufX reposu**
2. **Other → codemagic.yaml**

### 5c. Ortam Değişkenlerini Ekle
**Settings → Environment variables** bölümüne şunları ekle:

| Değişken | Değer | Secure |
|----------|-------|--------|
| `APP_STORE_CONNECT_PRIVATE_KEY` | .p8 dosyasının **tüm içeriği** (-----BEGIN... dahil) | ✅ |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID (10 karakter) | ✅ |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (UUID) | ✅ |
| `DEVELOPMENT_TEAM` | Apple Team ID (developer.apple.com → Üyelik) | ✅ |

### 5d. codemagic.yaml'daki DEGISTIR alanlarını doldur
```yaml
# codemagic.yaml içinde şunları değiştir:
bundle_identifier: com.DEGISTIR.TasarrufX  →  kendi bundle ID'n
BUNDLE_ID: "com.DEGISTIR.TasarrufX"         →  kendi bundle ID'n
recipients: - EMAILIN@BURAYA.COM                 →  kendi e-posta
```

---

## ADIM 6 — İlk Build (otomatik)

`main` branch'e push yapınca Codemagic otomatik başlar:

```
GitHub push → Codemagic tetiklenir
           → XcodeGen ile .xcodeproj oluşturulur
           → Sertifika Apple'dan indirilir
           → Uygulama derlenir
           → IPA imzalanır
           → TestFlight'a yüklenir
           → Sana e-posta gelir
```

**Süre:** ~15-20 dakika

---

## ADIM 7 — TestFlight Testi

1. appstoreconnect.apple.com → TestFlight sekmesi
2. Build'in hazır olmasını bekle (genellikle 30 dk - Apple işlemesi)
3. iPhone'un App Store'dan **TestFlight** uygulamasını indir
4. Seni test kullanıcısı olarak ekle → daveti kabul et
5. Uygulamayı test et

---

## ADIM 8 — App Store'da Yayınla

Test tamam olduktan sonra:

1. `codemagic.yaml` dosyasında:
```yaml
submit_to_app_store: false  →  submit_to_app_store: true
```
2. Push yap → Codemagic yeni build başlatır
3. appstoreconnect.apple.com → Uygulamann → Gözden Geçirilmeye Hazır
4. Fiyatlandırma: **Ücretsiz** (reklam gelirinle para kazanırsın)
5. **İncelemeye Gönder**

**Apple inceleme süresi:** 1-3 gün

---

## 🔴 Sık Yapılan Hatalar

### "No signing certificate found"
→ `DEVELOPMENT_TEAM` değişkeni eksik veya yanlış

### "Bundle ID already exists"
→ Başka bir uygulama bu Bundle ID'yi kullanıyor, farklı bir tane seç

### "Missing compliance"
→ App Store Connect'te İhracat Uyumu sorusunu yanıtla (Şifreleme kullanmıyor → Evet)

### "App Icon missing"
→ `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` dosyası eksik

### "Invalid Info.plist"
→ `project.yml` doldurduktan sonra `xcodegen generate` ile test et

---

## 💰 Codemagic Ücretsiz Plan Yeterli mi?

| | Ücretsiz | Pro |
|-|---------|-----|
| Build dakikası | 500 dk/ay | 3000 dk/ay |
| Mac mini M2 | ✅ | ✅ |
| 1 build | ~15-20 dk | ~15-20 dk |
| Aylık max build | ~25 | ~150 |

**Sonuç:** Başlangıç için fazlasıyla yeterli.

---

## 📱 Yasal Uyarı (App Store için zorunlu)

Uygulamada zaten var. Metadata kısmına da ekle:
> "Bu uygulama yatırım tavsiyesi vermez. Tüm hesaplamalar eğitim amaçlıdır."

App Store kategorisi: **Finance**
Yaş sınırı: **4+**
Gizlilik politikası: App Store bunu isteyebilir — ücretsiz bir Privacy Policy sayfası oluştur (privacypolicygenerator.info)
