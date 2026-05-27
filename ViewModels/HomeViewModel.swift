import Foundation
import CoreData

final class HomeViewModel: ObservableObject {
    @Published var netDeger:       Double = 0
    @Published var gunlukAlintilar: AlıntiModel?
    @Published var hedefTutar:     Double = 0
    @Published var hedefAdi:       String = ""

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        veriYukle()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDegisti),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func contextDegisti() {
        DispatchQueue.main.async { self.veriYukle() }
    }

    func veriYukle() {
        netDegerHesapla()
        hedefYukle()
        alintiSec()
    }

    private func netDegerHesapla() {
        let istek = NSFetchRequest<CDVarlik>(entityName: "CDVarlik")
        let varliklar = (try? context.fetch(istek)) ?? []
        netDeger = varliklar.reduce(0) { $0 + $1.deger }
    }

    private func hedefYukle() {
        // Hedef, AyarlarView tarafından UserDefaults'a kaydedilir
        hedefTutar = UserDefaults.standard.double(forKey: "hedefTutar")
        hedefAdi   = UserDefaults.standard.string(forKey: "hedefAd") ?? "Mali Hedef"
    }

    private func alintiSec() {
        guard let url  = Bundle.main.url(forResource: "alintilar", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let liste = try? JSONDecoder().decode([AlıntiModel].self, from: data),
              !liste.isEmpty
        else { return }

        // Her gün farklı alıntı göster
        let gunSayisi = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        gunlukAlintilar = liste[(gunSayisi - 1) % liste.count]
    }

    var hedefIlerleme: Double {
        guard hedefTutar > 0 else { return 0 }
        return min(netDeger / hedefTutar, 1.0)
    }
}
