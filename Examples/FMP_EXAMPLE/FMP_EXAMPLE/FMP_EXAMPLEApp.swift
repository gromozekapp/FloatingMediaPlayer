//
//  FMP_EXAMPLEApp.swift
//  FMP_EXAMPLE
//

import SwiftUI
import FloatingMediaPlayer
import AVFoundation

@main
struct FMP_EXAMPLEApp: App {

    init() {
        setupAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                BasicExample()
                    .tabItem {
                        Image(systemName: "play.circle")
                        Text("Basic")
                    }

                CustomConfigurationExample()
                    .tabItem {
                        Image(systemName: "slider.horizontal.3")
                        Text("Custom")
                    }

                PresetExamples()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Presets")
                    }
            }
        }
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
            #if DEBUG
            print("✅ Audio session configured")
            #endif
        } catch {
            #if DEBUG
            print("❌ Failed to configure audio session: \(error.localizedDescription)")
            #endif
        }
    }
}
