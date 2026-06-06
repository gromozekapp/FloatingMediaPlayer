//
//  main.swift
//  DemoApp
//
//  Created by Demo on 18.09.25.
//

import SwiftUI
import FloatingMediaPlayer

// Для macOS приложения
#if os(macOS)
@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#else
// Для iOS - используем обычный main
print("FloatingMediaPlayer Demo")
print("Этот демо работает только на macOS")
print("Для iOS используйте отдельное приложение")
#endif

struct ContentView: View {
    @State private var mediaURL: URL?
    @State private var showPlayer = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("FloatingMediaPlayer Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Демонстрация плавающего медиа плеера")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Button("Выбрать видео файл") {
                    selectMediaFile(type: .video)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Выбрать аудио файл") {
                    selectMediaFile(type: .audio)
                }
                .buttonStyle(.bordered)
                
                if let url = mediaURL {
                    Button("Показать плеер") {
                        showPlayer.toggle()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding()
        .overlay(
            Group {
                if showPlayer, let url = mediaURL {
                    FloatingVideoPlayerView(mediaURL: url)
                        .allowsHitTesting(true)
                        .zIndex(1000)
                }
            }
        )
    }
    
    private func selectMediaFile(type: MediaType) {
        // Для демо используем тестовые URL
        switch type {
        case .video:
            // Попробуем найти тестовое видео в Bundle
            if let url = Bundle.main.url(forResource: "sample_video", withExtension: "mp4") {
                mediaURL = url
            } else {
                // Используем URL из интернета для демо
                mediaURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
            }
        case .audio:
            // Попробуем найти тестовое аудио в Bundle
            if let url = Bundle.main.url(forResource: "sample_audio", withExtension: "mp3") {
                mediaURL = url
            } else {
                // Используем URL из интернета для демо
                mediaURL = URL(string: "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav")
            }
        case .unknown:
            break
        }
    }
}

// Простой детектор типа медиа
enum MediaType {
    case video
    case audio
    case unknown
}
