//
//  AudioSessionManager.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 22.09.25.
//

import AVFoundation
import Foundation

/// Audio session manager for stable media playback.
public class AudioSessionManager {
    public static let shared = AudioSessionManager()
    
    private var isSessionActive = false
    private var errorCount = 0
    private let maxErrors = 3
    
    private init() {
        setupAudioSession()
    }
    
    /// Configures the audio session.
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try audioSession.setActive(true)
            isSessionActive = true
            errorCount = 0
        } catch {
            #if DEBUG
            print("❌ Audio session setup failed: \(error.localizedDescription)")
            #endif
            isSessionActive = false
        }
        #else
        isSessionActive = true
        errorCount = 0
        #endif
    }
    
    /// Handles audio errors and resets the session after repeated failures.
    public func handleAudioError(_ error: Error) {
        errorCount += 1
        #if DEBUG
        print("🔊 Audio error (\(errorCount)/\(maxErrors)): \(error.localizedDescription)")
        #endif
        
        if errorCount >= maxErrors {
            #if DEBUG
            print("⚠️ Too many audio errors, attempting to reset session")
            #endif
            resetAudioSession()
        }
    }
    
    /// Resets the audio session.
    public func resetAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setupAudioSession()
            }
        } catch {
            #if DEBUG
            print("❌ Failed to reset audio session: \(error.localizedDescription)")
            #endif
        }
        #else
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupAudioSession()
        }
        #endif
    }
    
    /// Whether the audio session is in a healthy state.
    public var isHealthy: Bool {
        return isSessionActive && errorCount < maxErrors
    }
    
    /// Deactivates the audio session.
    public func deactivate() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
            isSessionActive = false
        } catch {
            #if DEBUG
            print("❌ Failed to deactivate audio session: \(error.localizedDescription)")
            #endif
        }
        #else
        isSessionActive = false
        #endif
    }
}
