import Foundation
import CoreData
import SwiftUI

final class VarlikViewModel: ObservableObject {
    @Published var varliklar: [CDVarlik] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        varliklarGetir()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDegisti),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func contextDegisti() {
        DispatchQueue.main.async { self.varliklarGetir() }
    }

    func varliklarGetir() {
        let istek = NSFetchRequest<CDVarlik>(entityName: "CDVarlik")
        istek.sortDescriptors = [NSSortDescriptor(key: "eklenmeTarihi", ascending: false)]
        varliklar = (try? context.fetch(istek)) ?? []
    }

    var toplamDeger: Double {
        varliklar.reduce(0) { $0 + $1.deger }
    }

    // Pasta grafik için kategori bazlı toplam
    var kategoriToplamları: [(kategori: VarlikKategori, deger: Double)] {
        var sozluk: [VarlikKategori: Double] = [:]
        for v in varliklar {
            sozluk[v.kategoriEnum, default: 0] += v.deger
        }
        return sozluk
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }

    // Listelemek için gruplama
    var grupluVarliklar: [VarlikKategori: [CDVarlik]] {
        Dictionary(grouping: varliklar) { $0.kategoriEnum }
    }

    func varlikEkle(ad: String, kategori: VarlikKategori, deger: Double, not: String) {
        let yeni = CDVarlik(context: context)
        yeni.id             = UUID()
        yeni.ad             = ad
        yeni.kategoriEnum   = kategori
        yeni.deger          = deger
        yeni.not            = not.isEmpty ? nil : not
        yeni.eklenmeTarihi  = Date()
        PersistenceController.shared.kaydet()
        HapticFeedback.success()
    }

    func varlikGuncelle(_ varlik: CDVarlik, ad: String, kategori: VarlikKategori, deger: Double, not: String) {
        varlik.ad           = ad
        varlik.kategoriEnum = kategori
        varlik.deger        = deger
        varlik.not          = not.isEmpty ? nil : not
        PersistenceController.shared.kaydet()
        HapticFeedback.medium()
    }

    func varlikSil(at offsets: IndexSet, kategori: VarlikKategori) {
        let liste = grupluVarliklar[kategori] ?? []
        offsets.forEach { context.delete(liste[$0]) }
        PersistenceController.shared.kaydet()
    }

    func varlikSilDirekt(_ varlik: CDVarlik) {
        context.delete(varlik)
        PersistenceController.shared.kaydet()
    }
}
