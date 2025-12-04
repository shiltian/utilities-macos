import SwiftUI

/// Represents a third-party package dependency
struct PackageCredit: Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let author: String
    let url: URL
    let license: String
    let licenseURL: URL?
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private let packages: [PackageCredit] = [
        PackageCredit(
            name: "Swift Markdown",
            version: "0.7.3",
            author: "Apple Inc.",
            url: URL(string: "https://github.com/apple/swift-markdown")!,
            license: "Apache License 2.0",
            licenseURL: URL(string: "https://github.com/apple/swift-markdown/blob/main/LICENSE.txt")
        ),
        PackageCredit(
            name: "Swift cmark",
            version: "0.7.1",
            author: "Swift Language",
            url: URL(string: "https://github.com/swiftlang/swift-cmark")!,
            license: "BSD 2-Clause",
            licenseURL: URL(string: "https://github.com/swiftlang/swift-cmark/blob/gfm/COPYING")
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // App Icon and Info
            appInfoSection

            Divider()
                .padding(.top, 16)

            // Acknowledgements
            acknowledgementsSection

            Spacer(minLength: 16)

            // Close button
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: 420, height: 480)
        .background(
            VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
        )
    }

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            Text("Utilities")
                .font(.system(size: 22, weight: .semibold, design: .rounded))

            Text("Version \(appVersion) (\(buildNumber))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("A collection of helpful developer utilities for macOS")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/shiltian/utilities-macos")!) {
                    Label("GitHub", systemImage: "link")
                        .font(.caption)
                }

                Link(destination: URL(string: "mailto:utilities-feedback@tianshilei.me")!) {
                    Label("Feedback", systemImage: "envelope")
                        .font(.caption)
                }
            }
            .padding(.top, 4)
        }
        .padding(.top, 24)
    }

    private var acknowledgementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acknowledgements")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Text("This application uses the following open source packages:")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(packages) { package in
                        PackageCreditRow(package: package)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}

/// NSVisualEffectView wrapper for SwiftUI
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct PackageCreditRow: View {
    let package: PackageCredit
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(package.name)
                    .font(.system(.body, design: .rounded, weight: .medium))

                Text("v\(package.version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(Capsule())

                Spacer()

                Button {
                    NSWorkspace.shared.open(package.url)
                } label: {
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Open in browser")
            }

            HStack(spacing: 4) {
                Text("by")
                    .foregroundStyle(.tertiary)
                Text(package.author)
                    .foregroundStyle(.secondary)
            }
            .font(.caption)

            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                if let licenseURL = package.licenseURL {
                    Link(package.license, destination: licenseURL)
                        .font(.caption)
                        .foregroundStyle(.blue)
                } else {
                    Text(package.license)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color.primary.opacity(0.05) : Color.primary.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    AboutView()
}
