import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private var alintilar: [AlıntiModel] = {
        guard let url  = Bundle.main.url(forResource: "alintilar", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([AlıntiModel].self, from: data)
        else { return [] }
        return list
    }()

    func izinIste() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func gunlukBildirimAyarla(saat: Int = 9, dakika: Int = 0) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard let alintilar = alintilar.randomElement() else { return }

        let icerik = UNMutableNotificationContent()
        icerik.title = "Günün Motivasyonu 💰"
        icerik.body  = "\"\(alintilar.metin)\" — \(alintilar.yazar)"
        icerik.sound = .default

        var bilesen = DateComponents()
        bilesen.hour   = saat
        bilesen.minute = dakika

        let tetikleyici = UNCalendarNotificationTrigger(dateMatching: bilesen, repeats: true)
        let istek = UNNotificationRequest(identifier: "gunluk_motivasyon", content: icerik, trigger: tetikleyici)
        UNUserNotificationCenter.current().add(istek) { _ in }
    }

    func bildirimleriIptalEt() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func izinDurumuKontrolEt(tamamlama: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { ayarlar in
            DispatchQueue.main.async { tamamlama(ayarlar.authorizationStatus) }
        }
    }
}
