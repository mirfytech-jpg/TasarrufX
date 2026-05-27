import Foundation
import CoreData
import SwiftUI

// MARK: - Varlık Kategorisi
enum VarlikKategori: String, CaseIterable, Codable, Identifiable {
    case nakit       = "Nakit"
    case kripto      = "Kripto"
    case hisse       = "Hisse Senedi"
    case altin       = "Altın & Gümüş"
    case gayrimenkul = "Gayrimenkul"
    case arac        = "Araç"
    case diger       = "Diğer"

    var id: String { rawValue }

    var ikon: String {
        switch self {
        case .nakit:       return "banknote.fill"
        case .kripto:      return "bitcoinsign.circle.fill"
        case .hisse:       return "chart.bar.fill"
        case .altin:       return "seal.fill"
        case .gayrimenkul: return "house.fill"
        case .arac:        return "car.fill"
        case .diger:       return "ellipsis.circle.fill"
        }
    }

    var renk: Color {
        switch self {
        case .nakit:       return Color(red: 0.20, green: 0.73, blue: 0.39)
        case .kripto:      return Color(red: 0.97, green: 0.60, blue: 0.10)
        case .hisse:       return Color(red: 0.20, green: 0.50, blue: 0.95)
        case .altin:       return Color(red: 0.95, green: 0.80, blue: 0.10)
        case .gayrimenkul: return Color(red: 0.60, green: 0.35, blue: 0.90)
        case .arac:        return Color(red: 0.90, green: 0.35, blue: 0.35)
        case .diger:       return Color(red: 0.50, green: 0.50, blue: 0.55)
        }
    }
}

// MARK: - Gider Kategorisi
enum GiderKategori: String, CaseIterable, Codable {
    case konut        = "Konut"
    case yiyecek      = "Yiyecek"
    case ulasim       = "Ulaşım"
    case faturalar    = "Faturalar"
    case eglence      = "Eğlence"
    case saglik       = "Sağlık"
    case egitim       = "Eğitim"
    case diger        = "Diğer"

    var ikon: String {
        switch self {
        case .konut:     return "house.fill"
        case .yiyecek:   return "fork.knife"
        case .ulasim:    return "car.fill"
        case .faturalar: return "bolt.fill"
        case .eglence:   return "tv.fill"
        case .saglik:    return "heart.fill"
        case .egitim:    return "book.fill"
        case .diger:     return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Alıntı Modeli
struct AlıntiModel: Codable, Identifiable {
    let id: Int
    let metin: String
    let yazar: String
}

// MARK: - Büyüme Veri Noktası
struct BuyumeNoktasi: Identifiable {
    let id = UUID()
    let yil: Int
    let toplam: Double
    let yatirim: Double

    var getiri: Double { toplam - yatirim }
}

// MARK: - Kilometre Taşı
struct KilometreTasi: Identifiable {
    let id = UUID()
    let etiket: String
    let tutar: Double
    let ulasılanYil: Int?
    var ulasildi: Bool { ulasılanYil != nil }
}

// MARK: - Core Data Nesneleri

@objc(CDVarlik)
class CDVarlik: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var ad: String?
    @NSManaged var kategori: String?
    @NSManaged var deger: Double
    @NSManaged var not: String?
    @NSManaged var eklenmeTarihi: Date?

    var kategoriEnum: VarlikKategori {
        get { VarlikKategori(rawValue: kategori ?? "") ?? .diger }
        set { kategori = newValue.rawValue }
    }
}

@objc(CDGider)
class CDGider: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var ad: String?
    @NSManaged var tutar: Double
    @NSManaged var kategori: String?

    var kategoriEnum: GiderKategori {
        get { GiderKategori(rawValue: kategori ?? "") ?? .diger }
        set { kategori = newValue.rawValue }
    }
}

@objc(CDHedef)
class CDHedef: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var ad: String?
    @NSManaged var hedefTutar: Double
    @NSManaged var bitis: Date?
}

// MARK: - Identifiable Conformance
extension CDVarlik: Identifiable {}
extension CDGider: Identifiable {}
extension CDHedef: Identifiable {}
