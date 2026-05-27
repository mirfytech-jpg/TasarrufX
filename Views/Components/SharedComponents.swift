import SwiftUI
import Charts

// MARK: - İstatistik Kartı
struct IstatistikKart: View {
    let baslik: String
    let deger: String
    let ikon: String
    let renk: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: ikon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(renk)
                Spacer()
            }
            Text(deger)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(baslik)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sectionCard()
    }
}

// MARK: - Bölüm Başlığı
struct BolumBaslik: View {
    let baslik: String
    var aksiyon: String? = nil
    var aksiyonIslevi: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            Text(baslik)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
            Spacer()
            if let aksiyon, let islem = aksiyonIslevi {
                Button(aksiyon, action: islem)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.growthGreen)
            }
        }
    }
}

// MARK: - Boş Durum
struct BosEkran: View {
    let ikon: String
    let baslik: String
    let aciklama: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: ikon)
                .font(.system(size: 52))
                .foregroundStyle(Color.growthGreen.opacity(0.7))
            Text(baslik)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
            Text(aciklama)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Pasta Grafik (Swift Charts SectorMark)
struct PastaGrafik: View {
    let veriler: [(kategori: VarlikKategori, deger: Double)]
    let toplamDeger: Double

    var body: some View {
        if veriler.isEmpty {
            BosEkran(
                ikon: "chart.pie",
                baslik: "Henüz Varlık Yok",
                aciklama: "Varlık ekleyince dağılım burada görünür."
            )
        } else {
            VStack(spacing: 20) {
                Chart(veriler, id: \.kategori.id) { veri in
                    SectorMark(
                        angle: .value("Değer", veri.deger),
                        innerRadius: .ratio(0.55),
                        angularInset: 2
                    )
                    .foregroundStyle(veri.kategori.renk)
                    .cornerRadius(5)
                }
                .frame(height: 220)
                .overlay {
                    VStack(spacing: 2) {
                        Text("Toplam")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(TLFormatter.compact(toplamDeger))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }

                // Lejant
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(veriler, id: \.kategori.id) { veri in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(veri.kategori.renk)
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(veri.kategori.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.primary)
                                Text(TLFormatter.format(veri.deger))
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

// MARK: - Para Girişi
struct ParaGirisAlani: View {
    let baslik: String
    @Binding var deger: String
    var placeholder: String = "0"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(baslik)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            HStack {
                Text("₺")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.growthGreen)
                TextField(placeholder, text: $deger)
                    .font(.system(size: 17, weight: .medium))
                    .keyboardType(.decimalPad)
            }
            .padding(14)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - İlerleme Çubuğu
struct IlerlemeCubugu: View {
    let ilerleme: Double
    var renk: Color = .growthGreen

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(renk.opacity(0.15))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(renk)
                    .frame(width: geo.size.width * CGFloat(ilerleme), height: 10)
                    .animation(.smooth, value: ilerleme)
            }
        }
        .frame(height: 10)
    }
}
