import SwiftUI

struct HomeView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var butceVM: BütçeViewModel
    @State private var netDegerGoster = false

    private var selamlama: String {
        let saat = Calendar.current.component(.hour, from: Date())
        switch saat {
        case 6..<12:  return "Günaydın 👋"
        case 12..<18: return "İyi günler 👋"
        default:      return "İyi akşamlar 👋"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Üst Net Değer Kartı
                    netDegerKarti
                        .padding(.top, 8)

                    // MARK: - Hızlı İstatistikler
                    hizliIstatistikler

                    // MARK: - Günün Motivasyonu
                    if let alintilar = homeVM.gunlukAlintilar {
                        motivasyonKarti(alintilar)
                    }

                    // MARK: - Hedef İlerlemesi
                    if homeVM.hedefTutar > 0 {
                        hedefKarti
                    }

                    // MARK: - Yasal Uyarı (küçük)
                    Text("Bu uygulama yatırım tavsiyesi vermez. Tüm veriler yalnızca bilgi amaçlıdır.")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color.screenBg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(selamlama)
                            .font(.system(size: 17, weight: .semibold))
                        Text(bugunTarih())
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                withAnimation(.smooth.delay(0.15)) { netDegerGoster = true }
                homeVM.veriYukle()
            }
        }
    }

    // MARK: - Alt Görünümler

    private var netDegerKarti: some View {
        VStack(spacing: 6) {
            Text("Net Değerim")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Text(TLFormatter.format(homeVM.netDeger))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText(value: homeVM.netDeger))
                .animation(.smooth, value: homeVM.netDeger)
                .opacity(netDegerGoster ? 1 : 0)
                .scaleEffect(netDegerGoster ? 1 : 0.85)

            Text("Tüm varlıklarınızın toplamı")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .primaryCard()
    }

    private var hizliIstatistikler: some View {
        HStack(spacing: 12) {
            IstatistikKart(
                baslik: "Aylık Gelir",
                deger: TLFormatter.compact(butceVM.aylikGelir),
                ikon: "arrow.down.circle.fill",
                renk: .growthGreen
            )
            IstatistikKart(
                baslik: "Aylık Gider",
                deger: TLFormatter.compact(butceVM.toplamGider),
                ikon: "arrow.up.circle.fill",
                renk: .red
            )
            IstatistikKart(
                baslik: "Tasarruf",
                deger: "%\(Int(butceVM.tasarrufOrani))",
                ikon: "chart.pie.fill",
                renk: .orange
            )
        }
    }

    private func motivasyonKarti(_ alintilar: AlıntiModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundStyle(Color.growthGreen)
                Text("Günün Sözü")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Text(""\(alintilar.metin)"")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .lineSpacing(4)
            Text("— \(alintilar.yazar)")
                .font(.system(size: 13))
                .foregroundStyle(Color.growthGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .primaryCard()
    }

    private var hedefKarti: some View {
        VStack(alignment: .leading, spacing: 14) {
            BolumBaslik(baslik: homeVM.hedefAdi.isEmpty ? "Mali Hedef" : homeVM.hedefAdi)

            IlerlemeCubugu(ilerleme: homeVM.hedefIlerleme)

            HStack {
                Text(TLFormatter.compact(homeVM.netDeger))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.growthGreen)
                Spacer()
                Text("%\(Int(homeVM.hedefIlerleme * 100))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(TLFormatter.compact(homeVM.hedefTutar))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .primaryCard()
    }

    private func bugunTarih() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
    }
}
