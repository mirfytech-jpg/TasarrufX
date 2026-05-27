import SwiftUI

struct GiderEkleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: BütçeViewModel

    var duzenlenecekGider: CDGider? = nil

    @State private var ad: String = ""
    @State private var tutarMetin: String = ""
    @State private var secilenKategori: GiderKategori = .konut
    @State private var hata: String? = nil

    private var baslik: String { duzenlenecekGider == nil ? "Gider Ekle" : "Gideri Düzenle" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Ad
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gider Adı")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("Örn: Kira, Elektrik Faturası", text: $ad)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Tutar
                    ParaGirisAlani(baslik: "Aylık Tutar", deger: $tutarMetin, placeholder: "0,00")

                    // Kategori
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kategori")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                            ForEach(GiderKategori.allCases, id: \.rawValue) { kat in
                                GiderKatButon(
                                    kategori: kat,
                                    secili: secilenKategori == kat
                                ) {
                                    HapticFeedback.light()
                                    withAnimation(.snappy) { secilenKategori = kat }
                                }
                            }
                        }
                    }

                    if let hata {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(hata)
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    Button(action: kaydet) {
                        Text("Kaydet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.growthGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color.screenBg)
            .navigationTitle(baslik)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                if let g = duzenlenecekGider {
                    ad              = g.ad ?? ""
                    tutarMetin      = String(g.tutar)
                    secilenKategori = g.kategoriEnum
                }
            }
        }
    }

    private func kaydet() {
        let temiz = tutarMetin.replacingOccurrences(of: ",", with: ".")
        guard let tutar = Double(temiz), tutar > 0 else {
            hata = "Geçerli bir tutar girin."; return
        }
        guard !ad.trimmingCharacters(in: .whitespaces).isEmpty else {
            hata = "Gider adı boş olamaz."; return
        }

        if let g = duzenlenecekGider {
            vm.giderGuncelle(g, ad: ad, tutar: tutar, kategori: secilenKategori)
        } else {
            vm.giderEkle(ad: ad, tutar: tutar, kategori: secilenKategori)
        }
        dismiss()
    }
}

private struct GiderKatButon: View {
    let kategori: GiderKategori
    let secili: Bool
    let aksiyon: () -> Void

    var body: some View {
        Button(action: aksiyon) {
            VStack(spacing: 6) {
                Image(systemName: kategori.ikon)
                    .font(.system(size: 18))
                    .foregroundStyle(secili ? .white : .red)
                Text(kategori.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(secili ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(secili ? Color.red : Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
