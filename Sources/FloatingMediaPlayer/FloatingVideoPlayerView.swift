//
//  FloatingVideoPlayerView.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import SwiftUI
#if os(iOS)
import AVKit
#endif
import AVFoundation
#if os(iOS)
import UIKit
#endif

// MARK: - Player State

enum PlayerState {
    case idle
    case loading
    case playing
    case paused
    case error(Error)
}

/// Плавающий медиа плеер с настраиваемыми координатами и поддержкой видео/аудио
public struct FloatingVideoPlayerView: View, Equatable {
    
    // MARK: - Properties
    
    /// URL медиа файла
    public let mediaURL: URL
    
    /// Конфигурация плеера
    public let configuration: FloatingPlayerConfiguration
    
    /// Делегат для получения событий
    public weak var delegate: MediaPlayerDelegate?
    
    // MARK: - State
    
    @StateObject private var mediaPlayerBox = MediaPlayerBox()
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var showControls: Bool = false
    @State private var controlsTimer: Timer?
    @State private var mediaType: MediaType = .unknown
    @State private var animationDebounceTimer: Timer?
    @State private var showProgressRing: Bool = true
    
    // MARK: - Performance & State Management
    @State private var playerState: PlayerState = .idle
    @State private var positionUpdateTimer: Timer?
    @State private var lastUpdateTime: Date = Date()
    @State private var errorCount: Int = 0
    @State private var isAudioSessionActive: Bool = false
    
    private let maxErrors = 3
    private let positionDebounceInterval: TimeInterval = 0.1
    private let maxUpdatesPerSecond = 10.0
    
    // MARK: - Initialization
    
    /// Инициализатор с URL медиа файла
    /// - Parameters:
    ///   - mediaURL: URL медиа файла
    ///   - configuration: Конфигурация плеера (по умолчанию используется стандартная)
    ///   - delegate: Делегат для получения событий
    public init(
        mediaURL: URL,
        configuration: FloatingPlayerConfiguration = FloatingPlayerConfiguration(),
        delegate: MediaPlayerDelegate? = nil
    ) {
        self.mediaURL = mediaURL
        self.configuration = configuration
        self.delegate = delegate
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Основное медиа окно
                ZStack {
                    mediaView
                        .frame(width: currentSize, height: currentSize)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(configuration.borderColor, lineWidth: configuration.borderWidth)
                        )
                        .shadow(
                            color: configuration.shadowColor,
                            radius: configuration.shadowRadius,
                            x: configuration.shadowOffset.width,
                            y: configuration.shadowOffset.height
                        )
                    
                           // Круговой прогресс-бар (показывается всегда)
                           if showProgressRing && ringDuration > 0 {
                               CircularProgressRing(
                                   progress: ringProgress,
                                   currentTime: ringCurrentTime,
                                   duration: ringDuration,
                                   size: currentSize, // Максимальный радиус по наружной кромке
                                   onProgressChanged: { newProgress in
                                       seekToProgress(newProgress)
                                   }
                               )
                               .frame(width: currentSize, height: currentSize)
                               .zIndex(1000)
                           }
                }
                       .scaleEffect(isDragging ? 1.1 : 1.0)
                       .animation(.easeInOut(duration: 0.2), value: isDragging)
                       .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showControls)
                       .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentSize)
                .offset(dragOffset)
                .gesture(dragGesture)
                .onTapGesture {
                    if configuration.showControls {
                        toggleControls()
                    }
                }
                
                // Элементы управления (появляются при нажатии)
                if showControls && configuration.showControls {
                    controlsView
                }
            }
            .position(calculatePosition(geometry: geometry))
            .onAppear {
                setupPlayer()
                if configuration.showControls {
                    resetControlsTimer()
                }
            }
            .onDisappear {
                cleanup()
            }
        }
    }
    
    // MARK: - Media View
    
    @ViewBuilder
    private var mediaView: some View {
        if let videoPlayer = mediaPlayerBox.player as? VideoPlayer {
            VideoPlayerView(videoPlayer: videoPlayer)
        } else {
            audioView
        }
    }
    
    private var audioView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: configuration.audioBackgroundColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: currentSize * 0.5))
                .foregroundColor(configuration.iconColor)
                .opacity(mediaPlayerBox.player?.isPlaying == true ? 1.0 : 0.7)
        }
    }
    
    // MARK: - Controls View
    
    private var controlsView: some View {
        HStack(spacing: 12) {
            // Кнопка назад
            Button(action: {
                mediaPlayerBox.player?.skipBackward()
            }) {
                Image(systemName: "gobackward.15")
                    .font(.title2)
                    .foregroundColor(configuration.iconColor)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            
            // Кнопка воспроизведения/паузы
            Button(action: {
                togglePlayPause()
            }) {
                Image(systemName: mediaPlayerBox.player?.isPlaying == true ? "pause.circle.fill" : "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(configuration.iconColor)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            
            // Кнопка вперед
            Button(action: {
                mediaPlayerBox.player?.skipForward()
            }) {
                Image(systemName: "goforward.15")
                    .font(.title2)
                    .foregroundColor(configuration.iconColor)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
        }
        .padding(8)
        .background(
            Circle()
                .fill(Color.black.opacity(0.3))
                .blur(radius: 1)
        )
    }
    
    // MARK: - Gestures
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if configuration.allowDragging {
                    isDragging = true
                    dragOffset = value.translation
                    if configuration.showControls {
                        showControls = true
                        resetControlsTimer()
                    }
                }
            }
            .onEnded { value in
                if configuration.allowDragging {
                    isDragging = false
                    let currentPosition = mediaPlayerBox.player?.floatingPosition ?? configuration.defaultPosition
                    let newPosition = CGPoint(
                        x: currentPosition.x + value.translation.width,
                        y: currentPosition.y + value.translation.height
                    )
                    
                    // Дебаунсинг для изменений позиции
                    debouncedPositionUpdate(newPosition)
                    dragOffset = .zero
                    
                    if configuration.showControls {
                        resetControlsTimer()
                    }
                }
            }
    }
    
    // MARK: - Private Methods
    
    private func setupPlayer() {
        playerState = .loading
        
        // Проверяем валидность URL
        guard !mediaURL.absoluteString.isEmpty else {
            #if DEBUG
            print("❌ Invalid media URL: empty or nil")
            #endif
            let error = NSError(domain: "FloatingMediaPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid media URL"])
            playerState = .error(error)
            handlePlayerError(error)
            return
        }
        
        // Проверяем существование файла
        guard FileManager.default.fileExists(atPath: mediaURL.path) else {
            #if DEBUG
            print("❌ Media file does not exist: \(mediaURL.path)")
            #endif
            let error = NSError(domain: "FloatingMediaPlayer", code: -2, userInfo: [NSLocalizedDescriptionKey: "Media file does not exist"])
            playerState = .error(error)
            handlePlayerError(error)
            return
        }
        
        // Настраиваем аудио сессию
        setupAudioSession()
        
        if configuration.autoDetectMediaType {
            mediaType = MediaTypeDetector.detectMediaType(from: mediaURL)
        }
        
        // Создаем плеер (MediaPlayerFactory.createPlayer не выбрасывает исключений)
        mediaPlayerBox.player = MediaPlayerFactory.createPlayer(for: mediaURL, delegate: delegate)
        
        if let player = mediaPlayerBox.player {
            // Устанавливаем начальную позицию и размер из конфигурации
            Task { @MainActor in
                player.updateFloatingPosition(configuration.defaultPosition)
                player.updateFloatingSize(configuration.defaultSize)
            }

            playerState = .idle
            
            if configuration.autoPlayOnAppear {
                Task { @MainActor in
                    player.play()
                    playerState = .playing
                }
            }
        } else {
            let error = NSError(domain: "FloatingMediaPlayer", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unsupported media format"])
            #if DEBUG
            print("❌ Failed to create player: \(error.localizedDescription)")
            #endif
            playerState = .error(error)
            handlePlayerError(error)
        }
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Проверяем, не активна ли уже сессия
            if audioSession.isOtherAudioPlaying {
                #if DEBUG
                print("⚠️ Other audio is playing, using mixWithOthers")
                #endif
            }
            
            // Используем более консервативную настройку для предотвращения конфликтов
            if #available(iOS 16.0, *) {
                // Новый API для iOS 16+ с более стабильными настройками
                try audioSession.setCategory(
                    .playback,
                    mode: .default, // Используем default вместо moviePlayback для стабильности
                    options: [.allowAirPlay, .allowBluetoothHFP, .mixWithOthers]
                )
                
                // Более консервативные настройки
                try audioSession.setPreferredSampleRate(44100.0) // Стандартная частота
                try audioSession.setPreferredIOBufferDuration(0.02) // 20ms для стабильности
                
            } else {
                // Fallback для старых версий
                try audioSession.setCategory(
                    .playback, 
                    mode: .default, 
                    options: [.allowAirPlay, .allowBluetoothHFP, .mixWithOthers]
                )
                try audioSession.setPreferredSampleRate(44100.0)
                try audioSession.setPreferredIOBufferDuration(0.02)
            }
            
            // Активируем сессию с обработкой ошибок
            try audioSession.setActive(true, options: [])
            isAudioSessionActive = true
            errorCount = 0
            
            #if DEBUG
            print("✅ Audio session configured successfully (iOS 16+ optimized)")
            #endif
        } catch {
            #if DEBUG
            print("❌ Audio session setup failed: \(error.localizedDescription)")
            #endif
            isAudioSessionActive = false
            // Не вызываем handlePlayerError для аудио ошибок, чтобы избежать циклов
            errorCount += 1
        }
        #else
        // Для macOS и других платформ аудио сессия не нужна
        #if DEBUG
        print("ℹ️ Audio session not needed on this platform")
        #endif
        isAudioSessionActive = true
        #endif
    }
    
    private func toggleControls() {
        // Добавляем debouncing для предотвращения частых переключений
        animationDebounceTimer?.invalidate()
        animationDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            showControls.toggle()
            resetControlsTimer()
        }
    }
    
    private func togglePlayPause() {
        guard let player = mediaPlayerBox.player else { return }
        
        if player.isPlaying {
            player.pause()
            playerState = .paused
        } else {
            player.play()
            playerState = .playing
        }
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: configuration.controlsTimeout, repeats: false) { _ in
            withAnimation(.easeOut(duration: configuration.animationDuration)) {
                showControls = false
            }
        }
    }
    
    private func calculatePosition(geometry: GeometryProxy) -> CGPoint {
        let playerPosition = mediaPlayerBox.player?.floatingPosition ?? configuration.defaultPosition
        
        // Если позиция player'а равна (0,0) или не задана, используем дефолтную позицию
        let finalPosition: CGPoint
        if playerPosition != CGPoint.zero {
            finalPosition = playerPosition
        } else {
            finalPosition = configuration.defaultPosition
        }
        
        // Проверяем, что позиция в пределах экрана
        let clampedX = max(configuration.minimumSize, min(finalPosition.x, geometry.size.width - configuration.minimumSize))
        let clampedY = max(configuration.minimumSize, min(finalPosition.y, geometry.size.height - configuration.minimumSize))
        
        return CGPoint(x: clampedX, y: clampedY)
    }
    
    private var currentSize: CGFloat {
        let playerSize = mediaPlayerBox.player?.floatingSize ?? configuration.defaultSize
        return max(configuration.minimumSize, min(playerSize, configuration.maximumSize))
    }
    
    private func cleanup() {
        controlsTimer?.invalidate()
        controlsTimer = nil
        animationDebounceTimer?.invalidate()
        animationDebounceTimer = nil
        positionUpdateTimer?.invalidate()
        positionUpdateTimer = nil
        
        // Деактивируем аудио сессию при очистке
        #if os(iOS)
        if isAudioSessionActive {
            do {
                try AVAudioSession.sharedInstance().setActive(false)
                isAudioSessionActive = false
            } catch {
                #if DEBUG
                print("❌ Failed to deactivate audio session: \(error.localizedDescription)")
                #endif
            }
        }
        #else
        isAudioSessionActive = false
        #endif
    }

    // MARK: - Progress Ring (computed)

    private var ringDuration: TimeInterval {
        max(0, mediaPlayerBox.player?.duration ?? 0)
    }

    private var ringCurrentTime: TimeInterval {
        max(0, mediaPlayerBox.player?.currentTime ?? 0)
    }

    private var ringProgress: Double {
        guard ringDuration > 0 else { return 0 }
        let p = ringCurrentTime / ringDuration
        if p.isNaN || p.isInfinite { return 0 }
        return max(0, min(1, p))
    }
    
    private func seekToProgress(_ progress: Double) {
        guard let player = mediaPlayerBox.player, ringDuration > 0 else { return }
        
        let newTime = progress * ringDuration
        
        if let videoPlayer = player as? VideoPlayer,
           let avPlayer = videoPlayer.player {
            let time = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            avPlayer.seek(to: time)
        } else if let audioPlayer = player as? AudioPlayer {
            // Для аудио плеера обновляем время
            audioPlayer.seek(to: newTime)
        }
    }
    
    private func handlePlayerError(_ error: Error) {
        errorCount += 1
        playerState = .error(error)
        
        #if DEBUG
        print("❌ Player error (\(errorCount)/\(maxErrors)): \(error.localizedDescription)")
        #endif
        
        // Сбрасываем аудио сессию при множественных ошибках
        if errorCount >= maxErrors {
            #if DEBUG
            print("⚠️ Too many errors, resetting audio session")
            #endif
            resetAudioSession()
        }
        
        // Уведомляем делегата
        if let player = mediaPlayerBox.player {
            delegate?.mediaPlayer(player, didEncounterError: error)
        }
    }
    
    private func resetAudioSession() {
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
    
    private func debouncedPositionUpdate(_ position: CGPoint) {
        positionUpdateTimer?.invalidate()
        positionUpdateTimer = Timer.scheduledTimer(withTimeInterval: positionDebounceInterval, repeats: false) { _ in
            Task { @MainActor in
                self.mediaPlayerBox.player?.updateFloatingPosition(position)
            }
        }
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: FloatingVideoPlayerView, rhs: FloatingVideoPlayerView) -> Bool {
        return lhs.mediaURL == rhs.mediaURL && 
               lhs.configuration == rhs.configuration
    }
}

// MARK: - VideoPlayerView для отображения видео

#if os(iOS)
public struct VideoPlayerView: UIViewRepresentable {
    @ObservedObject var videoPlayer: VideoPlayer
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        // Инициализируем coordinator
        context.coordinator.view = view
        
        if let player = videoPlayer.player {
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = view.bounds
            view.layer.addSublayer(playerLayer)
            
            // Сохраняем ссылку на playerLayer для обновления frame
            context.coordinator.playerLayer = playerLayer
        }
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        guard let playerLayer = context.coordinator.playerLayer else { return }
        let newFrame = uiView.bounds
        if playerLayer.frame != newFrame {
            playerLayer.frame = newFrame
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator {
        var playerLayer: AVPlayerLayer?
        weak var view: UIView?
        
        public init() {}
        
        deinit {
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
            view = nil
        }
    }
}
#else
// Для macOS используем простой placeholder
public struct VideoPlayerView: View {
    @ObservedObject var videoPlayer: VideoPlayer
    
    public var body: some View {
        Rectangle()
            .fill(Color.black)
            .overlay(
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            )
    }
}
#endif

// MARK: - Preview

struct FloatingVideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FloatingVideoPlayerView(
                mediaURL: URL(fileURLWithPath: "/test_video.mp4"),
                configuration: FloatingPlayerConfiguration.full
            )
            FloatingVideoPlayerView(
                mediaURL: URL(fileURLWithPath: "/test_audio.mp3"),
                configuration: FloatingPlayerConfiguration.minimal
            )
        }
        .background(Color.black)
    }
}
