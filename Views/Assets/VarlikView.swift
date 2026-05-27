import SwiftUI

struct VarlikView: View {
    @EnvironmentObject var vm: VarlikViewModel
    @State private var ekleSheet      = false
    @State private var duzenle: CDVarlik? = nil
    @State private var silOnay: CDVarlik? = nil

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Pasta Grafik
                    VStack(spacing: 0) {
                        PastaGrafik(
                            veriler: vm.kategoriToplamları,
                            toplamDeger: vm.toplamDeger
                        )
                    }
                    .padding(20)
                    .primaryCard()

                    // MARK: - Varlık Listesi
                    if vm.varliklar.isEmpty {
                        BosEkran(
                            ikon: "briefcase.fill",
                            baslik: "Henüz Varlık Eklenmedi",
                            aciklama: "Nakit, kripto, hisse veya diğer varlıklarını ekleyerek başla."
                        )
                    } else {
                        ForEach(VarlikKategori.allCases) { kategori in
                            let liste = vm.grupluVarliklar[kategori] ?? []
                            if !liste.isEmpty {
                                kategoriBlok(kategori: kategori, varliklar: liste)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.screenBg)
            .navigationTitle("Varlıklarım")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticFeedback.light()
                        ekleSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.growthGreen)
                    }
                }
            }
            .sheet(isPresented: $ekleSheet) {
                VarlikEkleSheet()
                    .environmentObject(vm)
            }
            .sheet(item: $duzenle) { varlik in
                VarlikEkleSheet(duzenlenecekVarlik: varlik)
                    .environmentObject(vm)
            }
            .confirmationDialog(
                "Bu varlığı silmek istiyor musunuz?",
                isPresented: Binding(
                    get: { silOnay != nil },
                    set: { if !$0 { silOnay = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Sil", role: .destructive) {
                    if let v = silOnay { vm.varlikSilDirekt(v) }
                    silOnay = nil
                }
                Button("İptal", role: .cancel) { silOnay = nil }
            }
        }
    }

    private func kategoriBlok(kategori: VarlikKategori, varliklar: [CDVarlik]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Kategori başlığı
            HStack(spacing: 8) {
                Image(systemName: kategori.ikon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(kategori.renk)
                Text(kategori.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                let toplam = varliklar.reduce(0) { $0 + $1.deger }
                Text(TLFormatter.compact(toplam))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(kategori.renk)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Divider().padding(.horizontal, 16)

            // Varlık satırları
            ForEach(varliklar, id: \.id) { varlik in
                VarlikSatir(varlik: varlik)
                    .contentShape(Rectangle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) { silOnay = varlik } label: {
                            Label("Sil", systemImage: "trash")
                        }
                        Button { duzenle = varlik } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                    .onTapGesture { duzenle = varlik }

                if varlik != varliklar.last {
                    Divider().padding(.leading, 56)
                }
            }
            .padding(.bottom, 12)
        }
        .primaryCard()
    }
}

private struct VarlikSatir: View {
    let varlik: CDVarlik

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(varlik.kategoriEnum.renk.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: varlik.kategoriEnum.ikon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(varlik.kategoriEnum.renk)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(varlik.ad ?? "—")
                    .font(.system(size: 15, weight: .medium))
                if let not = varlik.not, !not.isEmpty {
                    Text(not)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(TLFormatter.format(varlik.deger))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
