import SwiftUI
import UserNotifications

struct AyarlarView: View {
    @AppStorage("bildirimAktif")       private var bildirimAktif = true
    @AppStorage("bildirimSaati")       private var bildirimSaati = 9
    @AppStorage("hedefAd")            private var hedefAd = ""
    @AppStorage("hedefTutar")         private var hedefTutar: Double = 0

    @EnvironmentObject var varlikVM: VarlikViewModel
    @EnvironmentObject var butceVM:  BütçeViewModel

    @State private var silOnayGoster = false
    @State private var hedefTutarMetin = ""
    @State private var bildirimIzni: UNAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack {
            List {

                // MARK: - Hedef Bölümü
                Section {
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(Color.growthGreen)
                            .frame(width: 28)
                        TextField("Hedef adı (örn: Ev almak)", text: $hedefAd)
                            .font(.system(size: 15))
                    }
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(Color.growthGreen)
                            .frame(width: 28)
                        Text("₺")
                            .foregroundStyle(Color.growthGreen)
                            .font(.system(size: 15, weight: .semibold))
                        TextField("Hedef tutar", text: $hedefTutarMetin)
                            .keyboardType(.numberPad)
                            .font(.system(size: 15))
                            .onChange(of: hedefTutarMetin) { _, yeni in
                                let temiz = yeni.filter { $0.isNumber }
                                hedefTutarMetin = temiz
                                hedefTutar = Double(temiz) ?? 0
                            }
                    }
                } header: {
                    Text("Mali Hedef")
                } footer: {
                    Text("Hedef, Ana Sayfa'daki ilerleme çubuğunda gösterilir.")
                }

                // MARK: - Bildirimler
                Section {
                    Toggle(isOn: Binding(
                        get: { bildirimAktif },
                        set: { yeni in
                            bildirimAktif = yeni
                            if yeni {
                                NotificationManager.shared.izinIste()
                                NotificationManager.shared.gunlukBildirimAyarla(saat: bildirimSaati)
                            } else {
                                NotificationManager.shared.bildirimleriIptalEt()
                            }
                        }
                    )) {
                        Label("Günlük Motivasyon", systemImage: "bell.badge.fill")
                    }
                    .tint(Color.growthGreen)

                    if bildirimAktif {
                        Stepper("Saat: \(bildirimSaati):00", value: $bildirimSaati, in: 6...22) {
                            _ in
                            NotificationManager.shared.gunlukBildirimAyarla(saat: bildirimSaati)
                        }
                    }

                    if bildirimIzni == .denied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Bildirim izni reddedildi. Ayarlar'dan açabilirsiniz.")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Bildirimler")
                }

                // MARK: - Uygulama Hakkında
                Section {
                    HStack {
                        Label("Sürüm", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    Link(destination: URL(string: "https://www.apple.com/tr/ios/app-store/")!) {
                        Label("Uygulamayı Değerlendir", systemImage: "star.fill")
                            .foregroundStyle(.primary)
                    }
                } header: {
                    Text("Uygulama")
                }

                // MARK: - Yasal Uyarı
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundStyle(.orange)
                            Text("Yasal Uyarı")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        Text(yasal)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Hukuki")
                }

                // MARK: - Veri Yönetimi
                Section {
                    Button(role: .destructive) {
                        silOnayGoster = true
                    } label: {
                        Label("Tüm Verileri Sil", systemImage: "trash.fill")
                    }
                } header: {
                    Text("Veri")
                } footer: {
                    Text("Bu işlem geri alınamaz. Tüm varlık, gider ve hedef verileri silinir.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "Tüm veriler kalıcı olarak silinecek. Emin misiniz?",
                isPresented: $silOnayGoster,
                titleVisibility: .visible
            ) {
                Button("Sil", role: .destructive) { tumVerileriSil() }
                Button("İptal", role: .cancel) {}
            }
            .onAppear {
                if hedefTutar > 0 { hedefTutarMetin = String(Int(hedefTutar)) }
                NotificationManager.shared.izinDurumuKontrolEt { bildirimIzni = $0 }
            }
        }
    }

    private func tumVerileriSil() {
        let context = PersistenceController.shared.viewContext

        let varliklar = (try? context.fetch(NSFetchRequest<CDVarlik>(entityName: "CDVarlik"))) ?? []
        varliklar.forEach { context.delete($0) }

        let giderler = (try? context.fetch(NSFetchRequest<CDGider>(entityName: "CDGider"))) ?? []
        giderler.forEach { context.delete($0) }

        let hedefler = (try? context.fetch(NSFetchRequest<CDHedef>(entityName: "CDHedef"))) ?? []
        hedefler.forEach { context.delete($0) }

        PersistenceController.shared.kaydet()

        butceVM.aylikGelir   = 0
        hedefTutar           = 0
        hedefAd              = ""
        hedefTutarMetin      = ""

        HapticFeedback.medium()
    }

    private let yasal = """
    Bu uygulama yatırım tavsiyesi vermez ve finansal danışmanlık hizmeti sunmaz. \
    Gösterilen hesaplamalar yalnızca eğitim ve bilgi amaçlıdır. Herhangi bir yatırım \
    kararı vermeden önce lisanslı bir finansal danışmana başvurunuz. Uygulama \
    herhangi bir veri toplamaz; tüm bilgiler yalnızca cihazınızda saklanır.
    """
}
