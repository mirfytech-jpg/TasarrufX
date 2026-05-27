import SwiftUI

struct BütçeView: View {
    @EnvironmentObject var vm: BütçeViewModel
    @State private var gelirMetin: String = ""
    @State private var giderSheet = false
    @State private var duzenleGider: CDGider? = nil
    @FocusState private var gelirOdakli: Bool

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Gelir Kartı
                    gelirKarti

                    // MARK: - Tasarruf Özeti
                    if vm.aylikGelir > 0 {
                        tasarrufKarti
                    }

                    // MARK: - Giderler
                    giderlerKarti

                    // MARK: - Mesaj
                    if vm.aylikGelir > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.orange)
                            Text(vm.tasarrufMesaji())
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .sectionCard()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.screenBg)
            .navigationTitle("Bütçem")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticFeedback.light()
                        giderSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.growthGreen)
                    }
                }
            }
            .sheet(isPresented: $giderSheet) {
                GiderEkleSheet()
                    .environmentObject(vm)
            }
            .sheet(item: $duzenleGider) { gider in
                GiderEkleSheet(duzenlenecekGider: gider)
                    .environmentObject(vm)
            }
            .onAppear {
                if vm.aylikGelir > 0 {
                    gelirMetin = String(Int(vm.aylikGelir))
                }
            }
        }
    }

    // MARK: - Gelir Kartı
    private var gelirKarti: some View {
        VStack(alignment: .leading, spacing: 14) {
            BolumBaslik(baslik: "Aylık Net Gelir")

            HStack {
                Text("₺")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.growthGreen)
                TextField("0", text: $gelirMetin)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)
                    .focused($gelirOdakli)
                    .onChange(of: gelirMetin) { _, yeni in
                        let temiz = yeni.filter { $0.isNumber }
                        gelirMetin = temiz
                        vm.aylikGelir = Double(temiz) ?? 0
                    }
            }

            Text("Vergi ve kesintiler sonrası eline geçen miktar")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .primaryCard()
        .onTapGesture { gelirOdakli = true }
    }

    // MARK: - Tasarruf Kartı
    private var tasarrufKarti: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                TasarrufSatir(
                    baslik: "Toplam Gider",
                    deger: TLFormatter.format(vm.toplamGider),
                    renk: .red,
                    ikon: "arrow.up.circle.fill"
                )
                Divider().frame(height: 50)
                TasarrufSatir(
                    baslik: "Aylık Tasarruf",
                    deger: TLFormatter.format(vm.aylikTasarruf),
                    renk: .growthGreen,
                    ikon: "arrow.down.circle.fill"
                )
                Divider().frame(height: 50)
                TasarrufSatir(
                    baslik: "Tasarruf Oranı",
                    deger: "%\(Int(vm.tasarrufOrani))",
                    renk: .orange,
                    ikon: "chart.pie.fill"
                )
            }

            IlerlemeCubugu(ilerleme: vm.tasarrufOrani / 100)

            Text("Yıllık tahmini tasarruf: \(TLFormatter.format(vm.yillikTasarruf))")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.growthGreen)
        }
        .padding(20)
        .primaryCard()
    }

    // MARK: - Giderler Kartı
    private var giderlerKarti: some View {
        VStack(alignment: .leading, spacing: 0) {
            BolumBaslik(baslik: "Aylık Giderler")
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 14)

            if vm.giderler.isEmpty {
                BosEkran(
                    ikon: "creditcard.fill",
                    baslik: "Gider Eklenmedi",
                    aciklama: "Kira, fatura gibi sabit giderlerinizi ekleyin."
                )
                .padding(.bottom, 12)
            } else {
                ForEach(vm.giderler, id: \.id) { gider in
                    GiderSatir(gider: gider)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                if let idx = vm.giderler.firstIndex(of: gider) {
                                    vm.giderSil(at: IndexSet([idx]))
                                }
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                            Button { duzenleGider = gider } label: {
                                Label("Düzenle", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }

                    if gider != vm.giderler.last {
                        Divider().padding(.leading, 56)
                    }
                }
                .padding(.bottom, 12)

                Divider()
                HStack {
                    Text("Toplam")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text(TLFormatter.format(vm.toplamGider))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
        }
        .primaryCard()
    }
}

// MARK: - Gider Satırı
private struct GiderSatir: View {
    let gider: CDGider

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: gider.kategoriEnum.ikon)
                    .font(.system(size: 16))
                    .foregroundStyle(.red)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(gider.ad ?? "—")
                    .font(.system(size: 15, weight: .medium))
                Text(gider.kategoriEnum.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(TLFormatter.format(gider.tutar))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - Tasarruf Satırı
private struct TasarrufSatir: View {
    let baslik: String
    let deger: String
    let renk: Color
    let ikon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: ikon)
                .font(.system(size: 14))
                .foregroundStyle(renk)
            Text(deger)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(renk)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(baslik)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
