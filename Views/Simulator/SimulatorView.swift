import SwiftUI
import Charts

struct SimulatorView: View {
    @StateObject private var vm = SimulatorViewModel()
    @State private var grafikiGoster = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Parametreler
                    parametreKarti

                    // MARK: - Sonuç
                    sonucKarti
                        .opacity(grafikiGoster ? 1 : 0)
                        .offset(y: grafikiGoster ? 0 : 20)

                    // MARK: - Büyüme Grafiği
                    grafikKarti
                        .opacity(grafikiGoster ? 1 : 0)
                        .offset(y: grafikiGoster ? 0 : 30)

                    // MARK: - Kilometre Taşları
                    kilometre
                        .opacity(grafikiGoster ? 1 : 0)

                    Text("Bu hesaplamalar yalnızca eğitim amaçlıdır. Yatırım tavsiyesi değildir.")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color.screenBg)
            .navigationTitle("Bileşik Faiz Simülatörü")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.smooth.delay(0.2)) { grafikiGoster = true }
            }
        }
    }

    // MARK: - Parametre Kartı
    private var parametreKarti: some View {
        VStack(spacing: 20) {
            SliderSatir(
                baslik: "Başlangıç Tutarı",
                deger: $vm.baslangicTutar,
                aralik: 10_000...5_000_000,
                adim: 10_000
            )

            Divider()

            SliderSatir(
                baslik: "Aylık Katkı",
                deger: $vm.aylikKatkı,
                aralik: 0...50_000,
                adim: 500
            )

            Divider()

            // Faiz oranı
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Yıllık Getiri Oranı")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("%\(String(format: "%.1f", vm.yillikFaiz))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.growthGreen)
                }
                Slider(value: $vm.yillikFaiz, in: 1...100, step: 0.5)
                    .tint(Color.growthGreen)
            }

            Divider()

            // Yıl sayısı
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Yatırım Süresi")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(vm.yilSayisi) yıl")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.growthGreen)
                }
                Slider(value: Binding(
                    get: { Double(vm.yilSayisi) },
                    set: { vm.yilSayisi = Int($0) }
                ), in: 1...50, step: 1)
                    .tint(Color.growthGreen)
            }
        }
        .padding(20)
        .primaryCard()
    }

    // MARK: - Sonuç Kartı
    private var sonucKarti: some View {
        VStack(spacing: 16) {
            Text("Gelecek Değer")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Text(TLFormatter.format(vm.gelecegiDegeri))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Color.growthGreen)
                .contentTransition(.numericText(value: vm.gelecegiDegeri))
                .animation(.smooth, value: vm.gelecegiDegeri)

            Divider()

            HStack(spacing: 0) {
                SonucSatir(baslik: "Toplam Yatırım", deger: TLFormatter.compact(vm.toplamYatirim), renk: .primary)
                Divider().frame(height: 40)
                SonucSatir(baslik: "Faiz Getirisi", deger: TLFormatter.compact(vm.toplamGetiri), renk: .growthGreen)
                Divider().frame(height: 40)
                SonucSatir(baslik: "Büyüme", deger: "%\(Int(vm.buyumeOraniYuzde))", renk: .orange)
            }
        }
        .padding(20)
        .primaryCard()
    }

    // MARK: - Grafik
    private var grafikKarti: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Büyüme Grafiği")
                .font(.system(size: 17, weight: .semibold))

            Chart(vm.graffikVerileri) { nokta in
                AreaMark(
                    x: .value("Yıl", nokta.yil),
                    y: .value("Değer", nokta.toplam)
                )
                .foregroundStyle(LinearGradient.greenFade)

                LineMark(
                    x: .value("Yıl", nokta.yil),
                    y: .value("Değer", nokta.toplam)
                )
                .foregroundStyle(Color.growthGreen)
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                AreaMark(
                    x: .value("Yıl", nokta.yil),
                    y: .value("Yatırım", nokta.yatirim)
                )
                .foregroundStyle(Color.gray.opacity(0.08))

                LineMark(
                    x: .value("Yıl", nokta.yil),
                    y: .value("Yatırım", nokta.yatirim)
                )
                .foregroundStyle(Color.gray.opacity(0.4))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
            }
            .chartYAxis {
                AxisMarks(position: .leading) { deger in
                    AxisValueLabel {
                        if let v = deger.as(Double.self) {
                            Text(TLFormatter.compact(v))
                                .font(.system(size: 10))
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartXAxis {
                AxisMarks { deger in
                    AxisValueLabel {
                        if let v = deger.as(Int.self) {
                            Text("\(v)y")
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            .frame(height: 220)
            .animation(.smooth, value: vm.graffikVerileri.last?.toplam)

            // Lejant
            HStack(spacing: 20) {
                LejantSatir(renk: Color.growthGreen, etiket: "Toplam Değer")
                LejantSatir(renk: Color.gray.opacity(0.5), etiket: "Yatırılan Tutar", cizgi: true)
            }
        }
        .padding(20)
        .primaryCard()
    }

    // MARK: - Kilometre Taşları
    private var kilometre: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Kilometre Taşları")
                .font(.system(size: 17, weight: .semibold))

            ForEach(vm.kilometre) { tas in
                HStack(spacing: 14) {
                    Image(systemName: tas.ulasildi ? "checkmark.circle.fill" : "circle.dashed")
                        .font(.system(size: 22))
                        .foregroundStyle(tas.ulasildi ? Color.growthGreen : Color.secondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tas.etiket)
                            .font(.system(size: 15, weight: .semibold))
                        Text(TLFormatter.format(tas.tutar))
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let yil = tas.ulasılanYil {
                        Text("\(yil). yıl")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.growthGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.softGreen)
                            .clipShape(Capsule())
                    } else {
                        Text("Ulaşılamıyor")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(14)
                .sectionCard()
            }
        }
        .padding(20)
        .primaryCard()
    }
}

// MARK: - Yardımcı Görünümler

private struct SliderSatir: View {
    let baslik: String
    @Binding var deger: Double
    let aralik: ClosedRange<Double>
    let adim: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(baslik)
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Text(TLFormatter.compact(deger))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.growthGreen)
            }
            Slider(value: $deger, in: aralik, step: adim)
                .tint(Color.growthGreen)
        }
    }
}

private struct SonucSatir: View {
    let baslik: String
    let deger: String
    let renk: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(deger)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(renk)
            Text(baslik)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LejantSatir: View {
    let renk: Color
    let etiket: String
    var cizgi: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if cizgi {
                Rectangle()
                    .fill(renk)
                    .frame(width: 18, height: 2)
            } else {
                Rectangle()
                    .fill(renk)
                    .frame(width: 18, height: 3)
                    .clipShape(Capsule())
            }
            Text(etiket)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }
}
