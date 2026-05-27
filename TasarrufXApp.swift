import SwiftUI

@main
struct TasarrufXApp: App {
    let persistence = PersistenceController.shared

    @StateObject private var homeVM:   HomeViewModel
    @StateObject private var varlikVM: VarlikViewModel
    @StateObject private var butceVM:  BütçeViewModel

    @AppStorage("onboardingTamamlandi") private var onboardingTamamlandi = false

    init() {
        let ctx = PersistenceController.shared.viewContext
        _homeVM   = StateObject(wrappedValue: HomeViewModel(context: ctx))
        _varlikVM = StateObject(wrappedValue: VarlikViewModel(context: ctx))
        _butceVM  = StateObject(wrappedValue: BütçeViewModel(context: ctx))

        NotificationManager.shared.izinIste()
        if UserDefaults.standard.bool(forKey: "bildirimAktif") {
            let saat = UserDefaults.standard.integer(forKey: "bildirimSaati")
            NotificationManager.shared.gunlukBildirimAyarla(saat: saat == 0 ? 9 : saat)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingTamamlandi {
                    ContentView()
                        .environment(\.managedObjectContext, persistence.viewContext)
                        .environmentObject(homeVM)
                        .environmentObject(varlikVM)
                        .environmentObject(butceVM)
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
