import SwiftUI

struct VarlikEkleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: VarlikViewModel

    var duzenlenecekVarlik: CDVarlik? = nil

    @State private var ad: String = ""
    @State private var secilenKategori: VarlikKategori = .nakit
    @State private var degerMetin: String = ""
    @State private var notMetin: String = ""
    @State private var hataMesaji: String? = nil

    private var baslik: String { duzenlenecekVarlik == nil ? "Varlık Ekle" : "Varlığı Düzenle" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Ad
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Varlık Adı")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("Örn: Ziraat TL Hesabı", text: $ad)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Kategori
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kategori")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(VarlikKategori.allCases) { kategori in
                                KategoriButon(
                                    kategori: kategori,
                                    secili: secilenKategori == kategori
                                ) {
                                    HapticFeedback.light()
                                    withAnimation(.snappy) { secilenKategori = kategori }
                                }
                            }
                        }
                    }

                    // Değer
                    ParaGirisAlani(baslik: "Değer", deger: $degerMetin, placeholder: "0,00")

                    // Not
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Not (isteğe bağlı)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                        TextField("Hesap numarası, broker adı vb.", text: $notMetin)
                            .font(.system(size: 15))
                            .padding(14)
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    // Hata
                    if let hata = hataMesaji {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(hata)
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(.red)
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    // Kaydet Butonu
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
            .onAppear { mevcutDegerDoldur() }
        }
    }

    private func mevcutDegerDoldur() {
        guard let v = duzenlenecekVarlik else { return }
        ad              = v.ad ?? ""
        secilenKategori = v.kategoriEnum
        degerMetin      = String(v.deger)
        notMetin        = v.not ?? ""
    }

    private func kaydet() {
        let temizMetin = degerMetin.replacingOccurrences(of: ",", with: ".")
        guard let deger = Double(temizMetin), deger > 0 else {
            hataMesaji = "Geçerli bir tutar girin."
            return
        }
        guard !ad.trimmingCharacters(in: .whitespaces).isEmpty else {
            hataMesaji = "Varlık adı boş olamaz."
            return
        }

        if let v = duzenlenecekVarlik {
            vm.varlikGuncelle(v, ad: ad, kategori: secilenKategori, deger: deger, not: notMetin)
        } else {
            vm.varlikEkle(ad: ad, kategori: secilenKategori, deger: deger, not: notMetin)
        }
        dismiss()
    }
}

private struct KategoriButon: View {
    let kategori: VarlikKategori
    let secili: Bool
    let aksiyon: () -> Void

    var body: some View {
        Button(action: aksiyon) {
            VStack(spacing: 6) {
                Image(systemName: kategori.ikon)
                    .font(.system(size: 20))
                    .foregroundStyle(secili ? .white : kategori.renk)
                Text(kategori.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(secili ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(secili ? kategori.renk : Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
