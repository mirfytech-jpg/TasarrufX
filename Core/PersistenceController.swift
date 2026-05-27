import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "TasarrufX", managedObjectModel: Self.modelOlustur())
        container.loadPersistentStores { _, hata in
            if let hata { fatalError("Core Data yüklenemedi: \(hata)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func kaydet() {
        guard viewContext.hasChanges else { return }
        try? viewContext.save()
    }

    // MARK: - Programatik Core Data Modeli
    private static func modelOlustur() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let varlikEntity = varlikEntityOlustur()
        let giderEntity  = giderEntityOlustur()
        let hedefEntity  = hedefEntityOlustur()

        model.entities = [varlikEntity, giderEntity, hedefEntity]
        return model
    }

    private static func varlikEntityOlustur() -> NSEntityDescription {
        ozellikEkle(
            ad: "CDVarlik", sinif: "CDVarlik",
            ozellikler: [
                ("id",            .UUIDAttributeType,   true),
                ("ad",            .stringAttributeType, false),
                ("kategori",      .stringAttributeType, false),
                ("deger",         .doubleAttributeType, false),
                ("not",           .stringAttributeType, true),
                ("eklenmeTarihi", .dateAttributeType,   false)
            ]
        )
    }

    private static func giderEntityOlustur() -> NSEntityDescription {
        ozellikEkle(
            ad: "CDGider", sinif: "CDGider",
            ozellikler: [
                ("id",       .UUIDAttributeType,   true),
                ("ad",       .stringAttributeType, false),
                ("tutar",    .doubleAttributeType, false),
                ("kategori", .stringAttributeType, false)
            ]
        )
    }

    private static func hedefEntityOlustur() -> NSEntityDescription {
        ozellikEkle(
            ad: "CDHedef", sinif: "CDHedef",
            ozellikler: [
                ("id",         .UUIDAttributeType,   true),
                ("ad",         .stringAttributeType, false),
                ("hedefTutar", .doubleAttributeType, false),
                ("bitis",      .dateAttributeType,   true)
            ]
        )
    }

    private static func ozellikEkle(
        ad: String,
        sinif: String,
        ozellikler: [(String, NSAttributeType, Bool)]
    ) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = ad
        entity.managedObjectClassName = sinif
        entity.properties = ozellikler.map { isim, tip, opsiyonel in
            let attr = NSAttributeDescription()
            attr.name = isim
            attr.attributeType = tip
            attr.isOptional = opsiyonel
            if tip == .doubleAttributeType { attr.defaultValue = 0.0 }
            return attr
        }
        return entity
    }
}
