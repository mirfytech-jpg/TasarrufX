import Foundation
import CoreData

final class BütçeViewModel: ObservableObject {
    @Published var giderler: [CDGider] = []
    @AppStorage("aylikGelir") var aylikGelir: Double = 0

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        giderleriGetir()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDegisti),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func contextDegisti() {
        DispatchQueue.main.async { self.giderleriGetir() }
    }

    func giderleriGetir() {
        let istek = NSFetchRequest<CDGider>(entityName: "CDGider")
        istek.sortDescriptors = [NSSortDescriptor(key: "ad", ascending: true)]
        giderler = (try? context.fetch(istek)) ?? []
    }

    var toplamGider: Double {
        giderler.reduce(0) { $0 + $1.tutar }
    }

    var aylikTasarruf: Double {
        max(aylikGelir - toplamGider, 0)
    }

    var tasarrufOrani: Double {
        guard aylikGelir > 0 else { return 0 }
        return (aylikTasarruf / aylikGelir) * 100
    }

    var yillikTasarruf: Double {
        aylikTasarruf * 12
    }

    func giderEkle(ad: String, tutar: Double, kategori: GiderKategori) {
        let yeni = CDGider(context: context)
        yeni.id          = UUID()
        yeni.ad          = ad
        yeni.tutar        = tutar
        yeni.kategoriEnum = kategori
        PersistenceController.shared.kaydet()
        HapticFeedback.success()
    }

    func giderGuncelle(_ gider: CDGider, ad: String, tutar: Double, kategori: GiderKategori) {
        gider.ad          = ad
        gider.tutar        = tutar
        gider.kategoriEnum = kategori
        PersistenceController.shared.kaydet()
    }

    func giderSil(at offsets: IndexSet) {
        offsets.map { giderler[$0] }.forEach { context.delete($0) }
        PersistenceController.shared.kaydet()
    }

    func tasarrufMesaji() -> String {
        switch tasarrufOrani {
        case 30...:   return "Harika! Gelirinizin \(Int(tasarrufOrani))%'ini biriktiriyorsunuz 🚀"
        case 20..<30: return "İyi gidiyorsunuz! Hedef %30'un üzeri."
        case 10..<20: return "Güzel başlangıç. Giderlerinizi azaltmayı deneyin."
        case 0..<10:  return "Tasarruf oranınızı artırma zamanı!"
        default:      return "Aylık gelirinizi girin ve başlayın."
        }
    }
}
