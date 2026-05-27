import SwiftUI

struct ContentView: View {
    @EnvironmentObject var homeVM:   HomeViewModel
    @EnvironmentObject var varlikVM: VarlikViewModel
    @EnvironmentObject var butceVM:  BütçeViewModel
    @State private var secilenSekme: Sekme = .anasayfa

    enum Sekme {
        case anasayfa, simulator, varliklar, butce, ayarlar
    }

    var body: some View {
        TabView(selection: $secilenSekme) {

            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
                .tag(Sekme.anasayfa)

            SimulatorView()
                .tabItem {
                    Label("Simülatör", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Sekme.simulator)

            VarlikView()
                .tabItem {
                    Label("Varlıklar", systemImage: "briefcase.fill")
                }
                .tag(Sekme.varliklar)

            BütçeView()
                .tabItem {
                    Label("Bütçe", systemImage: "dollarsign.circle.fill")
                }
                .tag(Sekme.butce)

            AyarlarView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(Sekme.ayarlar)
        }
        .tint(Color.growthGreen)
    }
}
