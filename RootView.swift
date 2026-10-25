import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct RootView: View {
    @State private var selection = "Home"
    @State private var guestModel = GuestModel()

    var body: some View {
        ZStack {
            SpaceBackdrop()
            HStack(spacing: 0) {
                LauncherSidebar(selection: $selection, status: guestModel.sidebarStatus)
                OverviewPane(selection: selection, guestModel: guestModel, navigate: { selection = $0 })
            }
        }
        .frame(minWidth: 1040, minHeight: 700)
        .background(PickleTheme.canvas)
    }
}

private enum PickleTheme {
    static let canvas = Color(red: 0.015, green: 0.024, blue: 0.075)
    static let sidebar = Color(red: 0.012, green: 0.018, blue: 0.052).opacity(0.92)
    static let panel = Color(red: 0.055, green: 0.075, blue: 0.155).opacity(0.88)
    static let accent = Color(red: 0.28, green: 0.70, blue: 1.0)
    static let violet = Color(red: 0.48, green: 0.28, blue: 1.0)
    static let muted = Color.white.opacity(0.58)
}

private struct SpaceBackdrop: View {
    private let stars: [(CGFloat, CGFloat, CGFloat)] = [
        (0.08, 0.14, 2), (0.17, 0.32, 1), (0.27, 0.10, 1), (0.39, 0.22, 2),
        (0.52, 0.08, 1), (0.63, 0.31, 1), (0.76, 0.16, 2), (0.89, 0.28, 1),
        (0.13, 0.67, 1), (0.31, 0.84, 2), (0.47, 0.62, 1), (0.70, 0.78, 1),
        (0.84, 0.60, 2), (0.94, 0.88, 1), (0.58, 0.92, 1), (0.05, 0.92, 1)
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [PickleTheme.canvas, Color(red: 0.025, green: 0.015, blue: 0.10), PickleTheme.canvas],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(PickleTheme.violet.opacity(0.18))
                    .frame(width: proxy.size.width * 0.62)
                    .blur(radius: 90)
                    .offset(x: proxy.size.width * 0.32, y: -proxy.size.height * 0.20)
                Circle()
                    .fill(PickleTheme.accent.opacity(0.13))
                    .frame(width: proxy.size.width * 0.48)
                    .blur(radius: 80)
                    .offset(x: -proxy.size.width * 0.15, y: proxy.size.height * 0.42)
                ForEach(Array(stars.enumerated()), id: \.offset) { _, star in
                    Circle()
                        .fill(.white.opacity(star.2 == 2 ? 0.85 : 0.45))
                        .frame(width: star.2, height: star.2)
                        .position(x: proxy.size.width * star.0, y: proxy.size.height * star.1)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct LauncherSidebar: View {
    @Binding var selection: String
    let status: String
    private let items = [("Home", "house.fill", "1"), ("My Apps", "square.grid.2x2.fill", "2"), ("Game Center", "gamecontroller.fill", "3"), ("Instance Manager", "rectangle.3.group.fill", "4")]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "shippingbox.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(LinearGradient(colors: [PickleTheme.accent, PickleTheme.violet], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 1) {
                    Text(AppIdentity.name).font(.headline.weight(.bold)).foregroundStyle(.white)
                    Text("ANDROID DESKTOP").font(.system(size: 8, weight: .bold, design: .rounded)).tracking(1.2).foregroundStyle(PickleTheme.muted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 34)

            Text("WORKSPACE")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(PickleTheme.muted)
                .padding(.horizontal, 22)
                .padding(.bottom, 10)

            VStack(spacing: 5) {
                ForEach(items, id: \.0) { item in
                    Button {
                        selection = item.0
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.1).frame(width: 20)
                            Text(item.0)
                            Spacer()
                        }
                        .font(.callout.weight(selection == item.0 ? .semibold : .regular))
                        .foregroundStyle(selection == item.0 ? .white : PickleTheme.muted)
                        .padding(.horizontal, 13)
                        .frame(height: 42)
                        .background(selection == item.0 ? PickleTheme.accent.opacity(0.20) : .clear, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(KeyEquivalent(Character(item.2)), modifiers: [.command])
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            VStack(spacing: 5) {
                SidebarUtility(title: "Settings", symbol: "gearshape.fill") { selection = "Settings" }
                SidebarUtility(title: "Help Center", symbol: "questionmark.circle.fill") { selection = "Help Center" }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 18)

            HStack(spacing: 9) {
                Circle().fill(.green).frame(width: 8, height: 8)
                Text(status).font(.caption.weight(.medium)).foregroundStyle(PickleTheme.muted)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .frame(width: 224)
        .background(PickleTheme.sidebar)
    }
}

private struct SidebarUtility: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol).frame(width: 20)
                Text(title)
                Spacer()
            }
            .font(.callout)
            .foregroundStyle(PickleTheme.muted)
            .padding(.horizontal, 13)
            .frame(height: 42)
        }
        .buttonStyle(.plain)
    }
}

private struct OverviewPane: View {
    let selection: String
    let guestModel: GuestModel
    let navigate: (String) -> Void
    @State private var snapshot = SystemHostProbe().read()

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.5.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "5"
    }

    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? AppIdentity.bundleIdentifier
    }

    var body: some View {
        ScrollView {
            if selection == "Home" {
                homeContent
            } else {
                OptionPane(selection: selection, guestModel: guestModel)
                    .padding(30)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(PickleTheme.muted)
                        Text("Browse installed Android apps").font(.callout).foregroundStyle(PickleTheme.muted)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .frame(width: 330, height: 38)
                    .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 9))
                    .contentShape(RoundedRectangle(cornerRadius: 9))
                    .onTapGesture { navigate("My Apps") }
                    Spacer()
                    Button { navigate("Help Center") } label: { Image(systemName: "questionmark.circle").foregroundStyle(PickleTheme.muted) }
                        .buttonStyle(.plain)
                    Circle().fill(LinearGradient(colors: [PickleTheme.violet, PickleTheme.accent], startPoint: .top, endPoint: .bottom)).frame(width: 32, height: 32).overlay(Text("A").font(.caption.weight(.bold)).foregroundStyle(.white))
                }

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Good evening").font(.title2.weight(.medium)).foregroundStyle(PickleTheme.muted)
                        Text("Your Android desktop").font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    }
                    Spacer()
                    Text("\(version) • build \(build)").font(.caption.monospaced()).foregroundStyle(PickleTheme.muted)
                }

                HStack(spacing: 16) {
                    DashboardCard(title: "Launch your workspace", detail: "Prepare and start the configured Android runtime.", symbol: "play.fill", colors: [Color(red: 0.16, green: 0.29, blue: 0.62), Color(red: 0.24, green: 0.48, blue: 0.92)]) { guestModel.prepare() }
                    DashboardCard(title: "Performance center", detail: "Review runtime configuration and host hardware information.", symbol: "speedometer", colors: [Color(red: 0.29, green: 0.16, blue: 0.56), Color(red: 0.49, green: 0.28, blue: 0.82)]) { navigate("Instance Manager") }
                }

                BackendPerformanceSection(hostMemoryBytes: snapshot.physicalMemoryBytes, profile: guestModel.selectedProfile, backend: guestModel.backendSummary)

                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        Button { navigate("My Apps") } label: { SectionHeading(title: "My apps", action: "View all") }.buttonStyle(.plain)
                        HStack(spacing: 12) {
                            AppTile(title: "Android Guest", subtitle: "Virtual device", symbol: "shippingbox.fill", tint: PickleTheme.accent)
                            AppTile(title: "File Browser", subtitle: "Coming soon", symbol: "folder.fill", tint: .orange)
                            AppTile(title: "Playground", subtitle: "Coming soon", symbol: "wand.and.stars", tint: PickleTheme.violet)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeading(title: "Device status", action: nil)
                        GuestSection(model: guestModel)
                            .padding(16)
                            .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .frame(width: 330)
                }

                HostSection(facts: HostReport.facts(from: snapshot))
                    .padding(18)
                    .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 6) {
                    Text("About Pickle").font(.headline).foregroundStyle(.white)
                    Text(AppIdentity.summary).font(.callout).foregroundStyle(PickleTheme.muted).fixedSize(horizontal: false, vertical: true)
                    Text(bundleIdentifier).font(.caption.monospaced()).foregroundStyle(PickleTheme.muted)
                        .textSelection(.enabled)
                }
                .padding(18)
                .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(30)
    }
}

private struct OptionPane: View {
    let selection: String
    let guestModel: GuestModel
    @State private var packageName = ""
    @State private var gamePackageName = ""
    @State private var showAPKImporter = false
    @State private var availableInstances: [String] = []
    @State private var selectedInstance: String?
    @State private var packageSearch = ""

    private var filteredPackages: [String] {
        guestModel.installedPackages.filter { packageSearch.isEmpty || $0.localizedCaseInsensitiveContains(packageSearch) }
    }

    private var title: String { selection }

    private var detail: String {
        switch selection {
        case "My Apps": "Install, organize, and launch Android apps from your library."
        case "Game Center": "Choose a performance profile and launch your Android games."
        case "Instance Manager": "Create and manage Android virtual devices and runtime profiles."
        case "Settings": "Configure runtime, input, storage, and appearance preferences."
        default: "Find answers and diagnostics for Pickle."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.callout)
                    .foregroundStyle(PickleTheme.muted)
            }

            if selection == "My Apps" {
                appManagement
            } else if selection == "Game Center" {
                gameCenterPanel
            } else if selection == "Settings" {
                settingsPanel
            } else if selection == "Instance Manager" {
                instancePanel
            } else if selection == "Help Center" {
                helpPanel
            } else {
                HStack(spacing: 14) {
                    OptionCard(title: primaryActionTitle, detail: primaryActionDetail, symbol: primaryActionSymbol) { }
                    OptionCard(title: "Coming next", detail: "The next backend milestone will appear here.", symbol: "sparkles") { }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Pickle workspace")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("This section is connected to the main navigation and ready for the next runtime controls.")
                    .font(.callout)
                    .foregroundStyle(PickleTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var appManagement: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Button("Prepare Android backend") { guestModel.prepare() }
                    .disabled(guestModel.isBusy)
                Button("Boot guest") { guestModel.boot() }
                    .disabled(!guestModel.canBoot)
            }

            HStack(spacing: 12) {
                Button("Install APK") { showAPKImporter = true }
                    .disabled(!guestModel.isRunning)
                TextField("Package name, e.g. com.example.app", text: $packageName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 330)
                Button("Launch") { guestModel.launch(packageName: packageName) }
                    .disabled(!guestModel.isRunning || packageName.isEmpty)
                Button("Stop app") { guestModel.stop(packageName: packageName) }
                    .disabled(!guestModel.isRunning || packageName.isEmpty)
                Button("Check") { guestModel.checkPackage(packageName: packageName) }
                    .disabled(!guestModel.isRunning || packageName.isEmpty)
                Button("Uninstall") { guestModel.uninstall(packageName: packageName) }
                    .disabled(!guestModel.isRunning || packageName.isEmpty)
            }

            HStack(spacing: 10) {
                TextField("Search installed packages", text: $packageSearch)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 330)
                Button("Refresh apps") { Task { await guestModel.refreshInstalledPackages() } }
                    .disabled(!guestModel.isRunning || guestModel.isLoadingPackages)
                if guestModel.isLoadingPackages { ProgressView().controlSize(.small) }
            }

            if guestModel.installedPackages.isEmpty {
                Text(guestModel.isRunning ? "No third-party packages listed yet. Refresh to query Android." : "Start an Android Emulator guest to discover installed apps.")
                    .font(.callout).foregroundStyle(PickleTheme.muted)
            } else {
                ForEach(filteredPackages, id: \.self) { package in
                    HStack {
                        Image(systemName: "app.fill").foregroundStyle(PickleTheme.accent)
                        Text(package).font(.callout.monospaced()).foregroundStyle(.white).textSelection(.enabled)
                        Spacer()
                        Button("Launch") { guestModel.launch(packageName: package) }
                        Button("Select") { packageName = package }
                    }
                    .padding(.vertical, 3)
                }
            }

            if let status = guestModel.appStatus {
                Text(status)
                    .font(.callout)
                    .foregroundStyle(PickleTheme.muted)
                    .textSelection(.enabled)
            }
        }
        .padding(18)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
        .fileImporter(
            isPresented: $showAPKImporter,
            allowedContentTypes: [UTType(filenameExtension: "apk") ?? .data]
        ) { result in
            guard case let .success(url) = result else { return }
            guestModel.installAPK(at: url)
        }
    }

    private var settingsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Runtime profile")
                .font(.headline)
                .foregroundStyle(.white)
            Picker("Profile", selection: Binding(
                get: { guestModel.profileIdentifier },
                set: { guestModel.selectProfile(identifier: $0) }
            )) {
                Text("Battery").tag("battery")
                Text("Balanced").tag("balanced")
                Text("Performance").tag("performance")
            }
            .pickerStyle(.segmented)
            Text(guestModel.profileSummary)
                .font(.callout)
                .foregroundStyle(PickleTheme.muted)
            Text("Profile changes apply to the next Virtualization.framework guest. Android Emulator instances use their own AVD configuration.")
                .font(.caption)
                .foregroundStyle(PickleTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
    }

    private var gameCenterPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Button("Prepare game runtime") { guestModel.prepare() }
                    .disabled(guestModel.isBusy)
                Button("Boot game runtime") { guestModel.boot() }
                    .disabled(!guestModel.canBoot)
                Text(guestModel.stateLabel)
                    .font(.caption.monospaced())
                    .foregroundStyle(PickleTheme.muted)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Performance profile")
                    .font(.headline)
                    .foregroundStyle(.white)
                Picker("Profile", selection: Binding(
                    get: { guestModel.profileIdentifier },
                    set: { guestModel.selectProfile(identifier: $0) }
                )) {
                    Text("Battery").tag("battery")
                    Text("Balanced").tag("balanced")
                    Text("Performance").tag("performance")
                }
                .pickerStyle(.segmented)
            }

            HStack(spacing: 12) {
                TextField("Game package, e.g. com.example.game", text: $gamePackageName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 360)
                Button("Launch game") { guestModel.launch(packageName: gamePackageName) }
                    .disabled(!guestModel.isRunning || gamePackageName.isEmpty)
                Button("Stop game") { guestModel.stop(packageName: gamePackageName) }
                    .disabled(!guestModel.isRunning || gamePackageName.isEmpty)
            }

            Text("Game Center launches an installed game with the selected runtime profile. APK installation and package cleanup stay in My Apps.")
                .font(.caption)
                .foregroundStyle(PickleTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
    }

    private var instancePanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Android Emulator instances")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Refresh") { availableInstances = AndroidEmulatorSession.availableAVDs() }
            }

            if availableInstances.isEmpty {
                Text("No Android Emulator AVD was discovered. Install an ARM64 AVD and refresh.")
                    .font(.callout)
                    .foregroundStyle(PickleTheme.muted)
            } else {
                ForEach(availableInstances, id: \.self) { instance in
                    HStack {
                        Image(systemName: "iphone.gen3")
                            .foregroundStyle(PickleTheme.accent)
                        Text(instance)
                            .foregroundStyle(.white)
                        Spacer()
                        if selectedInstance == instance {
                            Text("Selected")
                                .font(.caption)
                                .foregroundStyle(PickleTheme.accent)
                        }
                        Button(selectedInstance == instance ? "Selected" : "Select") {
                            selectedInstance = instance
                        }
                        .disabled(selectedInstance == instance)
                        Text("Available")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }

            HStack(spacing: 10) {
                Button("Prepare selected runtime") { guestModel.prepare(avdName: selectedInstance) }
                    .disabled(guestModel.isBusy || selectedInstance == nil)
                Button("Boot") { guestModel.boot() }
                    .disabled(!guestModel.canBoot)
                Button("Stop") { guestModel.stop() }
                    .disabled(!guestModel.isRunning)
            }
        }
        .padding(18)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
        .task(id: selection) {
            availableInstances = AndroidEmulatorSession.availableAVDs()
            if selectedInstance == nil || !availableInstances.contains(selectedInstance ?? "") {
                selectedInstance = availableInstances.first
            }
        }
    }

    private var helpPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Diagnostics")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Use the runtime status on Home to prepare and boot a guest. Console logs are retained locally for troubleshooting.")
                .font(.callout)
                .foregroundStyle(PickleTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Button("Prepare diagnostics") { guestModel.prepare() }
                    .disabled(guestModel.isBusy)
                Button("Open log folder") { NSWorkspace.shared.open(ConsoleLog.directory) }
            }
            if let failureReason = guestModel.failureReason {
                Text(failureReason)
                    .font(.callout.monospaced())
                    .foregroundStyle(.orange)
                    .textSelection(.enabled)
            }
        }
        .padding(18)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
    }

    private var primaryActionTitle: String {
        switch selection {
        case "My Apps": "Install an APK"
        case "Game Center": "Choose a game"
        case "Instance Manager": "Create an instance"
        case "Settings": "Runtime settings"
        default: "Open diagnostics"
        }
    }

    private var primaryActionDetail: String {
        switch selection {
        case "My Apps": "APK installation will use the connected Android backend."
        case "Game Center": "Select a configured Android app to launch."
        case "Instance Manager": "Set memory, CPU, graphics, and storage profiles."
        case "Settings": "Tune Pickle for your Mac and Android runtime."
        default: "Review logs, runtime status, and troubleshooting steps."
        }
    }

    private var primaryActionSymbol: String {
        switch selection {
        case "My Apps": "square.and.arrow.down"
        case "Game Center": "gamecontroller.fill"
        case "Instance Manager": "plus.rectangle.on.rectangle"
        case "Settings": "slider.horizontal.3"
        default: "stethoscope"
        }
    }
}

private struct OptionCard: View {
    let title: String
    let detail: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(PickleTheme.accent.opacity(0.22), in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.headline.weight(.semibold)).foregroundStyle(.white)
                    Text(detail).font(.caption).foregroundStyle(PickleTheme.muted).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(PickleTheme.muted)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

private struct DashboardCard: View {
    let title: String
    let detail: String
    let symbol: String
    let colors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(.white.opacity(0.16), in: Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline.weight(.bold)).foregroundStyle(.white)
                Text(detail).font(.caption).foregroundStyle(.white.opacity(0.72)).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.72))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private struct AppTile: View {
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: symbol).font(.title3).foregroundStyle(tint).frame(width: 54, height: 54).background(tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
            Text(title).font(.callout.weight(.semibold)).foregroundStyle(.white).lineLimit(1)
            Text(subtitle).font(.caption).foregroundStyle(PickleTheme.muted)
        }
        .padding(14)
        .frame(width: 150, height: 142, alignment: .topLeading)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct SectionHeading: View {
    let title: String
    let action: String?

    var body: some View {
        HStack {
            Text(title).font(.headline).foregroundStyle(.white)
            Spacer()
            if let action { Text(action).font(.caption.weight(.semibold)).foregroundStyle(PickleTheme.accent) }
        }
    }
}

private struct BackendPerformanceSection: View {
    let hostMemoryBytes: UInt64?
    let profile: AndroidVMProfile
    let backend: String

    private var hostMemory: String {
        hostMemoryBytes.map(ByteText.gibibytes) ?? "Unavailable"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(title: "Backend configuration", action: "Configured values")
            HStack(spacing: 12) {
                PerformanceMetric(title: "Runtime", value: backend, symbol: "cpu")
                PerformanceMetric(title: "Profile vCPU", value: "\(profile.guestCPUCount) cores", symbol: "gauge.with.dots.needle.67percent")
                PerformanceMetric(title: "Profile memory", value: "\(profile.guestMemoryMiB) MiB", symbol: "memorychip")
                PerformanceMetric(title: "Host RAM total", value: hostMemory, symbol: "server.rack")
            }
        }
        .padding(18)
        .background(PickleTheme.panel, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct PerformanceMetric: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: symbol)
                .font(.callout.weight(.semibold))
                .foregroundStyle(PickleTheme.accent)
            Text(title)
                .font(.caption)
                .foregroundStyle(PickleTheme.muted)
            Text(value)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 11))
    }
}

/// Starts the guest and reports exactly what the guest said.
///
/// Every value shown here is read from the guest's own console output or from
/// the framework's own error. A stage the guest never reported is shown as
/// "not reached", never as a success.
private struct GuestSection: View {
    let model: GuestModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Android guest")
                    .font(.headline)
                Spacer()
                Text(model.stateLabel)
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
            }

            Text(model.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button("Prepare") { model.prepare() }
                    .disabled(model.isBusy)
                Button(model.isRunning ? "Stop" : "Boot") {
                    if model.isRunning { model.stop() } else { model.boot() }
                }
                .disabled(!model.canBoot)
            }

            if let logURL = model.consoleLogURL {
                HStack(spacing: 6) {
                    Text("Console log")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(logURL.lastPathComponent)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                }
            }

            if !model.stages.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(model.stages) { stage in
                        StageRow(stage: stage)
                    }
                }
                .padding(.top, 4)
            }

            if !model.blockerLines.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reported by the guest")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    ForEach(model.blockerLines, id: \.self) { line in
                        Text(line)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 4)
            }
        }
        .task {
            // Prepare on launch so Boot is usable, and boot immediately when
            // asked to from outside the app.
            if GuestLaunchOptions.bootOnLaunch {
                model.prepare()
            }
        }
    }
}

private struct StageRow: View {
    let stage: BootStage

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: stage.symbol)
                .foregroundStyle(stage.reached ? Color.accentColor : Color.secondary)
                .frame(width: 16)
            Text(stage.label)
                .font(.callout)
                .foregroundStyle(stage.reached ? .primary : .secondary)
            Spacer()
            Text(stage.reached ? "reached" : "not reached")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

/// Command-line and environment switches for driving Pickle without the UI.
///
/// `PICKLE_AUTOBOOT=1` prepares the discovered image and boots it on launch.
/// It exists so a boot can be driven and observed from a script or a CI log
/// rather than by clicking, and it uses the same `GuestModel` path the buttons
/// use, so it is not a separate code route.
enum GuestLaunchOptions {
    static let autoBootKey = "PICKLE_AUTOBOOT"

    /// Seconds to let the guest run before stopping and reporting.
    static let runSecondsKey = "PICKLE_RUN_SECONDS"

    static var bootOnLaunch: Bool {
        let raw = ProcessInfo.processInfo.environment[autoBootKey]
        return raw == "1" || raw == "true"
    }

    /// How long the auto-boot guest runs before it is stopped and reported.
    static var runSeconds: UInt64 {
        let raw = ProcessInfo.processInfo.environment[runSecondsKey]
        guard let value = raw.flatMap(UInt64.init), value > 0 else { return 60 }
        return value
    }
}

/// One observable step of the guest's own boot, as the guest reported it.
struct BootStage: Identifiable, Equatable {
    let id: String
    let label: String
    let reached: Bool

    var symbol: String {
        reached ? "checkmark.circle.fill" : "circle"
    }

    /// Build stages strictly from what the guest printed.
    static func stages(from report: GuestBootReport) -> [BootStage] {
        [
            BootStage(id: "kernel", label: "Linux kernel started", reached: report.kernelReachedUserspace),
            BootStage(id: "system", label: "/system mounted", reached: report.systemMounted),
            BootStage(id: "data", label: "/data mounted", reached: report.dataMounted),
            BootStage(id: "apex", label: "APEX packages restored", reached: report.apexdRestoredPackages),
            BootStage(id: "zygote", label: "zygote started", reached: report.zygoteStarted),
            BootStage(
                id: "gralloc",
                label: "graphics allocator (gralloc) available",
                reached: !report.graphicsAllocatorFailed
            ),
            BootStage(id: "surfaceflinger", label: "surfaceflinger stable", reached: !report.surfaceflingerRestarting),
            BootStage(id: "complete", label: "sys.boot_completed=1", reached: report.bootCompleted)
        ]
    }
}

/// Owns the guest session for the view.
@MainActor
@Observable
final class GuestModel {
    private(set) var state: GuestSessionState = .idle
    private(set) var report: GuestBootReport?
    private(set) var failureReason: String?
    private(set) var imageSummary: String?
    private(set) var consoleLogURL: URL?
    private(set) var appStatus: String?
    private(set) var installedPackages: [String] = []
    private(set) var isLoadingPackages = false
    private(set) var selectedProfile = AndroidVMProfile.balanced
    private var appOperationInProgress = false
    private var isConfiguring = false
    private var session: any GuestSession?
    private var stopTask: Task<Void, Never>?

    var isBusy: Bool { isConfiguring || state == .starting || state == .stopping }
    var isRunning: Bool { state == .running }
    var profileIdentifier: String { selectedProfile.identifier }
    var profileSummary: String {
        "\(selectedProfile.guestMemoryMiB) MiB guest memory • \(selectedProfile.guestCPUCount) vCPU • \(selectedProfile.identifier)"
    }

    var canBoot: Bool {
        !isBusy && (state == .configured || state == .stopped)
    }

    var stateLabel: String {
        switch state {
        case .idle: "Idle"
        case .configured: "Ready"
        case .starting: "Starting"
        case .running: "Running"
        case .stopping: "Stopping"
        case .stopped: "Stopped"
        case .failed: "Failed"
        }
    }

    var sidebarStatus: String {
        if session != nil { return "Android \(stateLabel.lowercased())" }
        if AndroidEmulatorSession.discover() != nil { return "Android Emulator found" }
        if let image = AndroidSystemImage.discover(), image.isUsable { return "Android image found" }
        return "No Android runtime found"
    }

    var backendSummary: String {
        if session is AndroidEmulatorSession { return "Android Emulator" }
        if session is VirtualMachineSession { return "Virtualization.framework" }
        if AndroidEmulatorSession.discover() != nil { return "Emulator available" }
        if let image = AndroidSystemImage.discover(), image.isUsable { return "VM image available" }
        return "Unavailable"
    }

    var stages: [BootStage] {
        report.map { BootStage.stages(from: $0) } ?? []
    }

    var blockerLines: [String] {
        report?.blockerLines ?? []
    }

    var detail: String {
        if let failureReason { return failureReason }
        guard let imageSummary else {
            return "No guest runtime is prepared."
        }
        switch state {
        case .idle, .configured:
            return "Image ready: \(imageSummary). Booting starts a real Android guest."
        case .starting:
            return "Starting the guest. The guest's own output appears after it stops."
        case .running:
            return "The guest is running. Stop it to read what it reported."
        case .stopping, .stopped:
            return "The guest stopped. Stages above are what it reported on its console."
        case .failed:
            return "The guest did not start."
        }
    }

    func prepare(avdName: String? = nil) {
        guard !isBusy, !isRunning else { return }
        isConfiguring = true
        report = nil
        consoleLogURL = nil
        failureReason = nil
        appStatus = nil
        if let emulatorSession = AndroidEmulatorSession.discover(avdName: avdName) {
            session = emulatorSession
            imageSummary = "ARM64 Android Emulator AVD available for display and input"
            configure(session: emulatorSession)
            return
        }
        guard let image = AndroidSystemImage.discover(), image.isUsable else {
            isConfiguring = false
            failureReason = "No usable guest runtime. Install an ARM64 Android Emulator AVD or run Scripts/prepare-android-image.sh."
            return
        }
        let virtualMachineSession = VirtualMachineSession(
            configuration: AndroidVMConfiguration(profile: selectedProfile, image: image, console: nil)
        )
        session = virtualMachineSession
        imageSummary = "Android \(image.apiLevel), arm64, \(image.componentNames.count) components"

        configure(session: virtualMachineSession)
    }

    private func configure(session: any GuestSession) {
        Task {
            let valid = await session.configure()
            isConfiguring = false
            failureReason = valid ? nil : session.failureReason
            state = session.state
            if valid, GuestLaunchOptions.bootOnLaunch {
                boot()
            }
        }
    }

    func boot() {
        guard let session else { return }
        state = .starting
        failureReason = nil
        stopTask = Task {
            await session.start()
            failureReason = session.failureReason
            state = session.state
            consoleLogURL = session.consoleLogURL
            if session.state == .running {
                if !GuestLaunchOptions.bootOnLaunch {
                    stopTask = nil
                    return
                }
                // Give the guest time to reach userspace before reading it.
                try? await Task.sleep(nanoseconds: GuestLaunchOptions.runSeconds * 1_000_000_000)
                state = .stopping
                await session.stop()
                report = session.report
                state = session.state
            }
            stopTask = nil
        }
    }

    func installAPK(at url: URL) {
        guard !appOperationInProgress else { return }
        guard let backend = session as? any AndroidAppBackend else {
            appStatus = "The active runtime does not expose Android package management."
            return
        }
        appStatus = "Installing \(url.lastPathComponent)…"
        appOperationInProgress = true
        Task {
            let hasSecurityScope = url.startAccessingSecurityScopedResource()
            defer {
                if hasSecurityScope { url.stopAccessingSecurityScopedResource() }
            }
            do {
                try await backend.installAPK(at: url)
                appStatus = "Installed \(url.lastPathComponent). Enter its package name to launch it."
            } catch {
                appStatus = error.localizedDescription
            }
            appOperationInProgress = false
            if appStatus?.hasPrefix("Installed ") == true { await refreshInstalledPackages() }
        }
    }

    func refreshInstalledPackages() async {
        guard !isLoadingPackages, !appOperationInProgress else { return }
        guard let backend = session as? any AndroidAppBackend else {
            appStatus = "The active runtime does not expose Android package management."
            return
        }
        isLoadingPackages = true
        defer { isLoadingPackages = false }
        do {
            installedPackages = try await backend.installedPackages()
            appStatus = "Found \(installedPackages.count) installed third-party packages."
        } catch {
            installedPackages = []
            appStatus = error.localizedDescription
        }
    }

    func launch(packageName: String) {
        runPackageOperation(packageName: packageName, operation: "Launching") { backend in
            try await backend.launch(packageName: packageName)
        }
    }

    func stop(packageName: String) {
        runPackageOperation(packageName: packageName, operation: "Stopping") { backend in
            try await backend.stop(packageName: packageName)
        }
    }

    func uninstall(packageName: String) {
        runPackageOperation(packageName: packageName, operation: "Uninstalling") { backend in
            try await backend.uninstall(packageName: packageName)
        }
    }

    func checkPackage(packageName: String) {
        guard let backend = session as? any AndroidAppBackend else {
            appStatus = "The active runtime does not expose Android package management."
            return
        }
        Task {
            let installed = await backend.isPackageInstalled(packageName)
            appStatus = installed ? "\(packageName) is installed." : "\(packageName) is not installed."
        }
    }

    func selectProfile(identifier: String) {
        guard !isBusy, !isRunning else {
            appStatus = "Stop the current guest before changing its runtime profile."
            return
        }
        switch identifier {
        case "battery": selectedProfile = .battery
        case "performance": selectedProfile = .performance
        default: selectedProfile = .balanced
        }
    }

    private func runPackageOperation(
        packageName: String,
        operation: String,
        action: @escaping (any AndroidAppBackend) async throws -> Void
    ) {
        guard !appOperationInProgress else { return }
        guard let backend = session as? any AndroidAppBackend else {
            appStatus = "The active runtime does not expose Android package management."
            return
        }
        appStatus = "\(operation) \(packageName)…"
        appOperationInProgress = true
        Task {
            do {
                try await action(backend)
                appStatus = "\(operation) complete for \(packageName)."
            } catch {
                appStatus = error.localizedDescription
            }
            appOperationInProgress = false
            if operation == "Uninstalling", appStatus?.hasPrefix("Uninstalling complete") == true {
                await refreshInstalledPackages()
            }
        }
    }

    func stop() {
        guard let session, isRunning else { return }
        stopTask?.cancel()
        state = .stopping
        Task {
            await session.stop()
            report = session.report
            failureReason = session.failureReason
            state = session.state
        }
    }
}

private struct HostSection: View {
    let facts: [HostFact]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("This Mac")
                    .font(.headline)
                Text("Values come from the kernel and the volume that holds your home folder.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 24, verticalSpacing: 10) {
                ForEach(facts) { fact in
                    GridRow {
                        Text(fact.label)
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.leading)
                        Text(fact.value)
                            .font(.body.monospacedDigit())
                            .foregroundStyle(fact.isAvailable ? .primary : .tertiary)
                            .textSelection(.enabled)
                            .gridColumnAlignment(.leading)
                    }
                }
            }
        }
    }
}

private struct FactCard: View {
    let eyebrow: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(title)
                .font(.title3.weight(.semibold))
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
