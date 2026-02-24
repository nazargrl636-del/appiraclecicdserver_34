import SwiftUI
import SwiftData
import AppsFlyerLib

let APPSFLYER_DEV_KEY = "6Z3eSp9L6WsPbPBdbvC7VA"
let APPLE_APP_ID = "6759047339"

@main
struct UtkonApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var targetUrlString: String?
    @State private var configState: ConfigRetrievalState = .pending
    @State private var currentViewState: ApplicationViewState = .initialScreen
    
    
    
    init() {
        Theme.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch currentViewState {
                case .initialScreen:
                    SplashScreenView()
                       
                    
                case .primaryInterface:
                    ContentView()
                        .onAppear {
                            Task {
                                await NotificationManager.shared.requestAuthorization()
                            }
                        }
                        
                    
                case .browserContent(let urlString):
                    if let validUrl = URL(string: urlString) {
                        BrowserContentView(targetUrl: validUrl.absoluteString)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .ignoresSafeArea(.all, edges: .bottom)
                    } else {
                        Text("Invalid URL")
                    }
                    
                case .failureMessage(let errorMessage):
                    VStack(spacing: 20) {
                        Text("Error")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(errorMessage)
                        Button("Retry") {
                            Task { await fetchConfigurationAndNavigate() }
                        }
                    }
                    .padding()
                }
            }
            .task {
                await fetchConfigurationAndNavigate()
            }
            .onChange(of: configState, initial: true) { oldValue, newValue in
                if case .completed = newValue, let url = targetUrlString, !url.isEmpty {
                    Task {
                        await verifyUrlAndNavigate(targetUrl: url)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Pet.self, CareTask.self])
    }
    
    private func fetchConfigurationAndNavigate() async {
        await MainActor.run { currentViewState = .initialScreen }
        
        let (url, state) = await DynamicConfigService.instance.retrieveTargetUrl()
        print("URL: \(url)")
        print("State: \(state)")
        
        await MainActor.run {
            self.targetUrlString = url
            self.configState = state
        }
        
        if url == nil || url?.isEmpty == true {
            navigateToPrimaryInterface()
        }
    }
    
    private func navigateToPrimaryInterface() {
        withAnimation {
            currentViewState = .primaryInterface
        }
    }
    
    private func verifyUrlAndNavigate(targetUrl: String) async {
        guard let url = URL(string: targetUrl) else {
            navigateToPrimaryInterface()
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        urlRequest.timeoutInterval = 10
        
        do {
            let (_, httpResponse) = try await URLSession.shared.data(for: urlRequest)
            
            if let response = httpResponse as? HTTPURLResponse,
               (200...299).contains(response.statusCode) {
                await MainActor.run {
                    currentViewState = .browserContent(targetUrl)
                }
            } else {
                navigateToPrimaryInterface()
            }
        } catch {
            navigateToPrimaryInterface()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        AppsFlyerLib.shared().appsFlyerDevKey = APPSFLYER_DEV_KEY
        AppsFlyerLib.shared().appleAppID = APPLE_APP_ID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = true
        
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity)
        return true
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("Conversion data: \(conversionInfo)")
    }
    
    func onConversionDataFail(_ error: Error) {
        print("Conversion data error: \(error.localizedDescription)")
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        print("App Open Attribution data: \(attributionData)")
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print("App Open Attribution error: \(error.localizedDescription)")
    }
}
