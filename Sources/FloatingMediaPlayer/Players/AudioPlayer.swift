//
//  AudioPlayer.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

#if os(iOS)
import AVKit
#endif
import SwiftUI
import MediaPlayer
import Combine

/// Audio player with floating window support
public final class AudioPlayer: NSObject, MediaPlayerProtocol, AVAudioPlayerDelegate, @unchecked Sendable {
    
    // MARK: - Published Properties
    
    @Published public var duration: Double = 0.0
    @Published public var currentTime: Double = 0.0
    @Published public var isPlaying: Bool = false
    @Published public var trackName: String = "-"
    @Published public var floatingPosition: CGPoint = CGPoint(x: 300, y: 500)
    @Published public var floatingSize: CGFloat = 160
    
    // MARK: - Public Properties
    
    public let mediaURL: URL
    public weak var delegate: MediaPlayerDelegate?
    
    // MARK: - Private Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var animationDebounceTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var nowPlayingInfo: [String: Any] = [:]
    private var lastNowPlayingUpdate: Date = .distantPast
    private let nowPlayingMinUpdateInterval: TimeInterval = 2.0
    
    // MARK: - Initialization
    
    public init(audioFileURL: URL, delegate: MediaPlayerDelegate? = nil) {
        self.mediaURL = audioFileURL
        self.delegate = delegate
        super.init()
        
        setupAudioPlayer()
        setupRemoteTransportControls()
        setupNowPlaying()
        startPlaybackTimer()
    }
    
    deinit {
        // Invalidate all timers
        playbackTimer?.invalidate()
        playbackTimer = nil
        animationDebounceTimer?.invalidate()
        animationDebounceTimer = nil
        
        // Tear down audio player
        audioPlayer?.stop()
        audioPlayer?.delegate = nil
        audioPlayer = nil
        
        // Remove Combine subscriptions
        cancellables.removeAll()
    }
    
    // MARK: - MediaPlayerProtocol Implementation
    
    public func play() {
        audioPlayer?.play()
        isPlaying = true
        startPlaybackTimer()
        updateNowPlaying(force: true)
        delegate?.mediaPlayerDidStartPlaying(self)
    }
    
    public func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopPlaybackTimer()
        updateNowPlaying(force: true)
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopPlaybackTimer()
        updateNowPlaying(force: true)
    }
    
    public func seek(to time: Double) {
        audioPlayer?.currentTime = time
        currentTime = time
        updateNowPlaying(force: true)
    }
    
    public func skipForward() {
        guard let audioPlayer = audioPlayer else { return }
        let newTime = audioPlayer.currentTime + 15
        audioPlayer.currentTime = newTime < audioPlayer.duration ? newTime : duration
        currentTime = audioPlayer.currentTime
    }
    
    public func skipBackward() {
        guard let audioPlayer = audioPlayer else { return }
        let newTime = audioPlayer.currentTime - 15
        audioPlayer.currentTime = newTime < 0.0 ? 0.0 : newTime
        currentTime = audioPlayer.currentTime
    }
    
    @MainActor public func updateFloatingPosition(_ position: CGPoint) {
        floatingPosition = position
        delegate?.mediaPlayerDidChangePosition(self, position: position)
    }
    
    @MainActor public func updateFloatingSize(_ size: CGFloat) {
        // Debounce to prevent animation conflicts
        animationDebounceTimer?.invalidate()
        animationDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.floatingSize = max(60, min(200, size))
                }
                self.delegate?.mediaPlayerDidChangeSize(self, size: self.floatingSize)
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            currentTime = 0
            stopPlaybackTimer()
            delegate?.mediaPlayerDidFinishPlaying(self)
        }
    }
    
    nonisolated public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            Task { @MainActor in
                delegate?.mediaPlayer(self, didEncounterError: error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioPlayer() {
        // AVAudioPlayer supports local files only
        if mediaURL.isFileURL {
            guard FileManager.default.fileExists(atPath: mediaURL.path) else {
                let error = NSError(domain: "AudioPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])
                delegate?.mediaPlayer(self, didEncounterError: error)
                return
            }
        } else {
            let error = NSError(domain: "AudioPlayer", code: -2, userInfo: [NSLocalizedDescriptionKey: "Remote audio URLs are not supported by AVAudioPlayer"])
            delegate?.mediaPlayer(self, didEncounterError: error)
            return
        }
        
        do {
            // Configure audio session
            setupAudioSession()
            
            // Create player
            audioPlayer = try AVAudioPlayer(contentsOf: mediaURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            
            duration = audioPlayer?.duration ?? 0.0
            trackName = mediaURL.lastPathComponent
            
        } catch {
            delegate?.mediaPlayer(self, didEncounterError: error)
        }
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        
        do {
            // Conservative settings to avoid conflicts
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try session.setActive(true, options: [])
        } catch {
            delegate?.mediaPlayer(self, didEncounterError: error)
        }
        #endif
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
        
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            self?.skipForward()
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            self?.skipBackward()
            return .success
        }
    }
    
    private func setupNowPlaying() {
        nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        updateNowPlaying(force: true)
    }
    
    private func updateNowPlaying(force: Bool) {
        let now = Date()
        if !force, now.timeIntervalSince(lastNowPlayingUpdate) < nowPlayingMinUpdateInterval {
            return
        }
        lastNowPlayingUpdate = now

        nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        // Increase interval to reduce CPU load
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let audioPlayer = self.audioPlayer, self.isPlaying else { return }

                // Debounce to prevent frequent updates
                let newTime = audioPlayer.currentTime
                if abs(newTime - self.currentTime) > 0.1 {
                    self.currentTime = newTime
                    self.updateNowPlaying(force: false)
                }
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
