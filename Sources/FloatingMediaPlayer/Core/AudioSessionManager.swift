//
//  AudioSessionManager.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 22.09.25.
//

import AVFoundation
import Foundation

/// Менеджер аудио сессии для стабильной работы с медиа
public class AudioSessionManager {
    public static let shared = AudioSessionManager()
    
    private var isSessionActive = false
    private var errorCount = 0
    private let maxErrors = 3
    
    private init() {
        setupAudioSession()
    }
    
    /// Настройка аудио сессии
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetoothHFP])
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
        // Для macOS и других платформ аудио сессия не нужна
        isSessionActive = true
        errorCount = 0
        #endif
    }
    
    /// Обработка ошибок аудио
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
    
    /// Сброс аудио сессии
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
        // Для macOS и других платформ просто перезапускаем настройку
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupAudioSession()
        }
        #endif
    }
    
    /// Проверка состояния аудио сессии
    public var isHealthy: Bool {
        return isSessionActive && errorCount < maxErrors
    }
    
    /// Деактивация аудио сессии
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
        // Для macOS и других платформ просто деактивируем
        isSessionActive = false
        #endif
    }
}
