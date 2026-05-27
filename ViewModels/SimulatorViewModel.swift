import Foundation
import Combine

final class SimulatorViewModel: ObservableObject {
    @Published var baslangicTutar: Double = 100_000
    @Published var aylikKatkı:     Double = 1_000
    @Published var yillikFaiz:     Double = 15
    @Published var yilSayisi:      Int    = 10

    var gelecegiDegeri: Double {
        hesapla(yil: yilSayisi)
    }

    var toplamYatirim: Double {
        baslangicTutar + aylikKatkı * Double(yilSayisi * 12)
    }

    var toplamGetiri: Double {
        gelecegiDegeri - toplamYatirim
    }

    var buyumeOraniYuzde: Double {
        guard toplamYatirim > 0 else { return 0 }
        return (gelecegiDegeri / toplamYatirim - 1) * 100
    }

    var graffikVerileri: [BuyumeNoktasi] {
        (0...yilSayisi).map { yil in
            let yatirim = baslangicTutar + aylikKatkı * Double(yil * 12)
            return BuyumeNoktasi(
                yil: yil,
                toplam: hesapla(yil: yil),
                yatirim: yatirim
            )
        }
    }

    var kilometre: [KilometreTasi] {
        let hedefler: [(String, Double)] = [
            ("500K",    500_000),
            ("1 Milyon", 1_000_000),
            ("5 Milyon", 5_000_000),
            ("10 Milyon", 10_000_000),
            ("2x",      baslangicTutar * 2)
        ]

        return hedefler
            .filter { $0.1 > baslangicTutar }
            .sorted { $0.1 < $1.1 }
            .map { etiket, tutar in
                let yil = yilBul(hedef: tutar)
                return KilometreTasi(etiket: etiket, tutar: tutar, ulasılanYil: yil)
            }
    }

    // FV = PV*(1+r)^n + PMT*((1+r)^n - 1)/r
    private func hesapla(yil: Int) -> Double {
        let r = yillikFaiz / 100 / 12
        let n = Double(yil * 12)

        let birikmisAnapara = baslangicTutar * pow(1 + r, n)

        let birikmisKatki: Double
        if r > 0 {
            birikmisKatki = aylikKatkı * (pow(1 + r, n) - 1) / r
        } else {
            birikmisKatki = aylikKatkı * n
        }

        return birikmisAnapara + birikmisKatki
    }

    private func yilBul(hedef: Double) -> Int? {
        for y in 1...100 {
            if hesapla(yil: y) >= hedef { return y }
        }
        return nil
    }
}
