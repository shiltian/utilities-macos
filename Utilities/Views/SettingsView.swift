import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        TabView {
            GeneralSettingsTab(settings: settings)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
        }
        .frame(width: 450, height: 200)
    }
}

// MARK: - General Settings Tab

struct GeneralSettingsTab: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settings.enableExperimentalFeatures) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Experimental Features")
                            .font(.body)
                        Text("Show AMDGPU tools like LLVM MC and SP3 Converter")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Label("Experimental", systemImage: "flask")
                    .font(.headline)
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
    }
}

#Preview {
    SettingsView()
}

