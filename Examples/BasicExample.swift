//
//  BasicExample.swift
//  FloatingMediaPlayer Examples
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import SwiftUI
import FloatingMediaPlayer
import UIKit
import PhotosUI
import UniformTypeIdentifiers

//MARK: Простой пример использования FloatingVideoPlayerView
struct BasicExample: View {
    @State private var mediaURL: URL?
    @State private var showPlayer = false
    @State private var showDocumentPicker = false
    @State private var showMediaPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Floating Media Player Example")
                .font(.title2)
                .fontWeight(.bold)
            
            // Кнопки выбора медиа
            HStack(spacing: 15) {
                Button("Выбрать из файлов") {
                    showDocumentPicker = true
                }
                .buttonStyle(.bordered)
                
                Button("Выбрать из галереи") {
                    showMediaPicker = true
                }
                .buttonStyle(.bordered)
            }
            
            // Информация о выбранном файле
            if let url = mediaURL {
                VStack(spacing: 8) {
                    Text("Выбранный файл:")
                        .font(.headline)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Воспроизвести") {
                        showPlayer = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Очистить") {
                        mediaURL = nil
                        showPlayer = false
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedURL: $mediaURL)
        }
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker(selectedURL: $mediaURL)
        }
        .overlay(
            Group {
                if showPlayer, let url = mediaURL {
                    FloatingPlayerWithProgress(mediaURL: url)
                        .zIndex(1000)
                }
            }
        )
    }
}

//MARK: Пример с кастомной конфигурацией
struct CustomConfigurationExample: View {
    @State private var mediaURL: URL?
    @State private var showPlayer = false
    @State private var showDocumentPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Кастомная конфигурация")
                .font(.title2)
                .fontWeight(.semibold)
            
            Button("Выбрать медиа файл") {
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)
            
            if let url = mediaURL {
                VStack(spacing: 8) {
                    Text("Выбранный файл:")
                        .font(.headline)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Показать плеер с кастомной конфигурацией") {
                        showPlayer.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedURL: $mediaURL)
        }
        .overlay(
            Group {
                if showPlayer, let url = mediaURL {
                    FloatingPlayerWithProgress(
                        mediaURL: url,
                        configuration: customConfiguration,
                        delegate: playerDelegate
                    )
                    .zIndex(1000)
                }
            }
        )
    }
    
    private var customConfiguration: FloatingPlayerConfiguration {
        FloatingPlayerConfiguration(
            defaultPosition: CGPoint(x: 200, y: 300),
            defaultSize: 140,
            showControls: true,
            controlsTimeout: 4.0,
            borderColor: .red,
            borderWidth: 3,
            shadowColor: .blue.opacity(0.5),
            shadowRadius: 15,
            audioBackgroundColors: [.purple, .pink],
            allowDragging: true
        )
    }
    
    private let playerDelegate = ExamplePlayerDelegate()
}

//MARK: Пример с делегатом
class ExamplePlayerDelegate: MediaPlayerDelegate {
    func mediaPlayerDidStartPlaying(_ player: any MediaPlayerProtocol) {
        print("🎵 Воспроизведение началось: \(player.trackName)")
    }
    
    func mediaPlayerDidFinishPlaying(_ player: any MediaPlayerProtocol) {
        print("✅ Воспроизведение завершено: \(player.trackName)")
    }
    
    func mediaPlayerDidChangePosition(_ player: any MediaPlayerProtocol, position: CGPoint) {
        print("📍 Позиция изменена: \(position)")
    }
    
    func mediaPlayerDidChangeSize(_ player: any MediaPlayerProtocol, size: CGFloat) {
        print("📏 Размер изменен: \(size)")
    }
    
    func mediaPlayer(_ player: any MediaPlayerProtocol, didEncounterError error: Error) {
        print("❌ Ошибка: \(error.localizedDescription)")
    }
}

//MARK: Пример с готовыми пресетами
struct PresetExamples: View {
    @State private var selectedPreset: PresetType = .minimal
    @State private var showPlayer = false
    @State private var mediaURL: URL?
    @State private var showDocumentPicker = false
    
    enum PresetType: String, CaseIterable {
        case minimal = "Минимальный"
        case compact = "Компактный"
        case full = "Полный"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Готовые пресеты")
                .font(.title2)
                .fontWeight(.semibold)
            
            Picker("Пресет", selection: $selectedPreset) {
                ForEach(PresetType.allCases, id: \.self) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            
            Button("Выбрать медиа файл") {
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)
            
            if let url = mediaURL {
                VStack(spacing: 8) {
                    Text("Выбранный файл:")
                        .font(.headline)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Показать плеер с пресетом") {
                        showPlayer.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedURL: $mediaURL)
        }
        .overlay(
            Group {
                if showPlayer, let url = mediaURL {
                    FloatingPlayerWithProgress(
                        mediaURL: url,
                        configuration: currentConfiguration
                    )
                    .zIndex(1000)
                }
            }
        )
    }
    
    private var currentConfiguration: FloatingPlayerConfiguration {
        switch selectedPreset {
        case .minimal:
            return .minimal
        case .compact:
            return .compact
        case .full:
            return .full
        }
    }
}

//MARK: Главный пример приложения
struct FloatingMediaPlayerExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                BasicExample()
                    .tabItem {
                        Image(systemName: "play.circle")
                        Text("Базовый")
                    }
                
                CustomConfigurationExample()
                    .tabItem {
                        Image(systemName: "slider.horizontal.3")
                        Text("Кастомный")
                    }
                
                PresetExamples()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Пресеты")
                    }
            }
        }
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            UTType.movie, UTType.video, UTType.audio, UTType.image
        ])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            let success = url.startAccessingSecurityScopedResource()
            if success {
                DispatchQueue.main.async {
                    self.parent.selectedURL = url
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Media Picker
struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.any(of: [.videos, .images])
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            DispatchQueue.main.async {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
            
            guard let result = results.first else { return }
            
            // Простая обработка - копируем файл в Documents
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                guard let self = self, let tempURL = url else { return }
                
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(UUID().uuidString).\(tempURL.pathExtension)"
                let permanentURL = documentsPath.appendingPathComponent(fileName)
                
                do {
                    try FileManager.default.copyItem(at: tempURL, to: permanentURL)
                    DispatchQueue.main.async {
                        self.parent.selectedURL = permanentURL
                    }
                } catch {
                    print("Ошибка копирования файла: \(error)")
                }
            }
        }
    }
}
