import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingTamamlandi") private var tamamlandi = false
    @State private var sayfaIndeksi = 0

    private let sayfalar: [OnboardingSayfasi] = [
        OnboardingSayfasi(
            ikon: "chart.line.uptrend.xyaxis",
            baslik: "Bileşik Faizin Gücü",
            aciklama: "Küçük miktarlar zamanla inanılmaz servetlere dönüşür. 20 yılda paranız 4 katına çıkabilir — sadece sabırlı olun.",
            renk: Color.growthGreen
        ),
        OnboardingSayfasi(
            ikon: "briefcase.fill",
            baslik: "Tüm Varlıklarını Takip Et",
            aciklama: "Nakit, kripto, hisse senedi, altın, gayrimenkul — hepsini tek bir yerde manuel olarak kaydet ve net değerini gör.",
            renk: Color(red: 0.20, green: 0.50, blue: 0.95)
        ),
        OnboardingSayfasi(
            ikon: "flame.fill",
            baslik: "Finansal Disiplin Kur",
            aciklama: "Günlük motivasyon bildirimleri, bütçe takibi ve hedef sistemiyle para alışkanlıklarını geliştir.",
            renk: Color(red: 0.97, green: 0.60, blue: 0.10)
        )
    ]

    var body: some View {
        ZStack {
            Color.screenBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sayfa göstergesi
                HStack(spacing: 8) {
                    ForEach(0..<sayfalar.count, id: \.self) { i in
                        Capsule()
                            .fill(i == sayfaIndeksi ? Color.growthGreen : Color.growthGreen.opacity(0.2))
                            .frame(width: i == sayfaIndeksi ? 28 : 8, height: 8)
                            .animation(.snappy, value: sayfaIndeksi)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // İçerik
                TabView(selection: $sayfaIndeksi) {
                    ForEach(0..<sayfalar.count, id: \.self) { i in
                        SayfaIcerigi(sayfa: sayfalar[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Buton
                VStack(spacing: 16) {
                    Button {
                        HapticFeedback.medium()
                        if sayfaIndeksi < sayfalar.count - 1 {
                            withAnimation(.snappy) { sayfaIndeksi += 1 }
                        } else {
                            withAnimation(.smooth) { tamamlandi = true }
                        }
                    } label: {
                        Text(sayfaIndeksi == sayfalar.count - 1 ? "Başla" : "Devam")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.growthGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    Text("Bu uygulama yatırım tavsiyesi vermez.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

private struct OnboardingSayfasi {
    let ikon: String
    let baslik: String
    let aciklama: String
    let renk: Color
}

private struct SayfaIcerigi: View {
    let sayfa: OnboardingSayfasi

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(sayfa.renk.opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: sayfa.ikon)
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(sayfa.renk)
            }

            VStack(spacing: 14) {
                Text(sayfa.baslik)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(sayfa.aciklama)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
