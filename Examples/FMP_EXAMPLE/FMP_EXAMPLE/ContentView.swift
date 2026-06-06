//
//  ContentView.swift
//  FMP_EXAMPLE
//

import FloatingMediaPlayer
import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Basic example

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

            HStack(spacing: 15) {
                Button("Choose from Files") {
                    showDocumentPicker = true
                }
                .buttonStyle(.bordered)

                Button("Choose from Photos") {
                    showMediaPicker = true
                }
                .buttonStyle(.bordered)
            }

            if let url = mediaURL {
                VStack(spacing: 8) {
                    Text("Selected file:")
                        .font(.headline)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Play") {
                        showPlayer = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Clear") {
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
        .overlay {
            if showPlayer, let url = mediaURL {
                FloatingVideoPlayerView(mediaURL: url)
                    .zIndex(1000)
            }
        }
    }
}

// MARK: - Custom configuration example

struct CustomConfigurationExample: View {
    @State private var mediaURL: URL?
    @State private var showPlayer = false
    @State private var showDocumentPicker = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Configuration")
                .font(.title2)
                .fontWeight(.semibold)

            Button("Choose media file") {
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)

            if let url = mediaURL {
                VStack(spacing: 8) {
                    Text("Selected file:")
                        .font(.headline)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Show player with custom config") {
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
        .overlay {
            if showPlayer, let url = mediaURL {
                FloatingVideoPlayerView(
                    mediaURL: url,
                    configuration: customConfiguration,
                    delegate: playerDelegate
                )
                .zIndex(1000)
            }
        }
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

// MARK: - Delegate example

final class ExamplePlayerDelegate: MediaPlayerDelegate {
    func mediaPlayerDidStartPlaying(_ player: any MediaPlayerProtocol) {
        print("▶️ Started: \(player.trackName)")
    }

    func mediaPlayerDidFinishPlaying(_ player: any MediaPlayerProtocol) {
        print("✅ Finished: \(player.trackName)")
    }

    func mediaPlayerDidChangePosition(_ player: any MediaPlayerProtocol, position: CGPoint) {
        print("📍 Position: \(position)")
    }

    func mediaPlayerDidChangeSize(_ player: any MediaPlayerProtocol, size: CGFloat) {
        print("📏 Size: \(size)")
    }

    func mediaPlayer(_ player: any MediaPlayerProtocol, didEncounterError error: Error) {
        print("❌ Error: \(error.localizedDescription)")
    }
}

// MARK: - Preset examples

struct PresetExamples: View {
    @State private var selectedPreset: PresetType = .minimal
    @State private var showPlayer = false
    @State private var mediaURL: URL?
    @State private var showDocumentPicker = false

    enum PresetType: String, CaseIterable {
        case minimal = "Minimal"
        case compact = "Compact"
        case full = "Full"
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Configuration Presets")
                .font(.title2)
                .fontWeight(.semibold)

            Picker("Preset", selection: $selectedPreset) {
                ForEach(PresetType.allCases, id: \.self) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(.segmented)

            Button("Choose media file") {
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)

            if let url = mediaURL {
                VStack(spacing: 8) {
                    Text("Selected file:")
                        .font(.headline)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Show player with preset") {
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
        .overlay {
            if showPlayer, let url = mediaURL {
                FloatingVideoPlayerView(
                    mediaURL: url,
                    configuration: currentConfiguration
                )
                .zIndex(1000)
            }
        }
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

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.dismiss) private var dismiss

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

            if url.startAccessingSecurityScopedResource() {
                parent.selectedURL = url
            }
            parent.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - Media Picker

struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Environment(\.dismiss) private var dismiss

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
            parent.dismiss()

            guard let result = results.first else { return }

            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                guard let tempURL = url else { return }

                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileName = "\(UUID().uuidString).\(tempURL.pathExtension)"
                let permanentURL = documentsPath.appendingPathComponent(fileName)

                do {
                    try FileManager.default.copyItem(at: tempURL, to: permanentURL)
                    DispatchQueue.main.async {
                        self.parent.selectedURL = permanentURL
                    }
                } catch {
                    #if DEBUG
                    print("Failed to copy file: \(error)")
                    #endif
                }
            }
        }
    }
}
