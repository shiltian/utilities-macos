import SwiftUI
import Observation

/// Application settings stored in UserDefaults
@Observable
final class AppSettings {
    private static let defaults = UserDefaults.standard

    // MARK: - Keys
    private enum Keys {
        static let enableExperimentalFeatures = "enableExperimentalFeatures"
    }

    // MARK: - Experimental Features

    /// Whether experimental AMDGPU features are enabled
    var enableExperimentalFeatures: Bool {
        didSet {
            AppSettings.defaults.set(enableExperimentalFeatures, forKey: Keys.enableExperimentalFeatures)
        }
    }

    // MARK: - Singleton for app-wide access
    static let shared = AppSettings()

    private init() {
        // Load initial value from UserDefaults
        self.enableExperimentalFeatures = AppSettings.defaults.bool(forKey: Keys.enableExperimentalFeatures)
    }
}

