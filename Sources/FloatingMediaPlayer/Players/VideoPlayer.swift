//
//  VideoPlayer.swift
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

/// Video player with floating window support
public final class VideoPlayer: NSObject, MediaPlayerProtocol, @unchecked Sendable {
    
    // MARK: - Published Properties
    
    @Published public var duration: Double = 0.0
    @Published public var currentTime: Double = 0.0
    @Published public var isPlaying: Bool = false
    @Published public var trackName: String = "-"
    @Published public var floatingPosition: CGPoint = CGPoint(x: 300, y: 500)
    @Published public var floatingSize: CGFloat = 160
    
    // MARK: - Public Properties
    
    public let mediaURL: URL
    
    public var isPictureInPictureActive: Bool = false
    
    public weak var delegate: MediaPlayerDelegate?
    
    // MARK: - Private Properties
    
    private var avPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    #if os(iOS)
    private var pipController: AVPictureInPictureController?
    #endif
    private var animationDebounceTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(videoFileURL: URL, delegate: MediaPlayerDelegate? = nil) {
        self.mediaURL = videoFileURL
        self.delegate = delegate
        super.init()
        
        setupVideoPlayer()
        setupPictureInPicture()
        setupRemoteTransportControls()
        setupNowPlaying()
        setupTimeObserver()
        
        // Delay to allow video duration to be loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateDuration()
        }
    }
    
    deinit {
        // Invalidate animation timer
        animationDebounceTimer?.invalidate()
        animationDebounceTimer = nil
        
        // Remove timeObserver synchronously
        if let timeObserver = timeObserver {
            avPlayer?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // Tear down Picture-in-Picture
        #if os(iOS)
        pipController?.stopPictureInPicture()
        pipController = nil
        #endif
        
        // Invalidate observers
        statusObservation?.invalidate()
        statusObservation = nil
        NotificationCenter.default.removeObserver(self)
        
        // Tear down player
        avPlayer?.pause()
        avPlayer = nil
        playerItem = nil
        
        // Remove Combine subscriptions
        cancellables.removeAll()
    }
    
    // MARK: - MediaPlayerProtocol Implementation
    
    public func play() {
        avPlayer?.play()
        isPlaying = true
        delegate?.mediaPlayerDidStartPlaying(self)
    }
    
    public func pause() {
        avPlayer?.pause()
        isPlaying = false
    }
    
    public func stop() {
        avPlayer?.pause()
        avPlayer?.seek(to: .zero)
        isPlaying = false
    }
    
    public func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        avPlayer?.seek(to: cmTime)
    }
    
    public func skipForward() {
        guard let currentTime = avPlayer?.currentTime() else { return }
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 15, preferredTimescale: 600))
        avPlayer?.seek(to: newTime)
    }
    
    public func skipBackward() {
        guard let currentTime = avPlayer?.currentTime() else { return }
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 15, preferredTimescale: 600))
        avPlayer?.seek(to: newTime)
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
                // Fix animation issue by removing conflicting animations
                let newSize = max(60, min(200, size))
                if abs(self.floatingSize - newSize) > 1.0 { // Only if the change is significant
                    self.floatingSize = newSize
                    self.delegate?.mediaPlayerDidChangeSize(self, size: self.floatingSize)
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    public func togglePictureInPicture() {
        #if os(iOS)
        guard let pipController = pipController else { return }
        
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
        #endif
    }
    
    public var player: AVPlayer? {
        return avPlayer
    }
    
    // MARK: - Private Methods
    
    private func setupVideoPlayer() {
        // Check local file exists (skip remote URLs — AVPlayer loads them)
        if mediaURL.isFileURL {
            guard FileManager.default.fileExists(atPath: mediaURL.path) else {
                let error = NSError(domain: "VideoPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])
                delegate?.mediaPlayer(self, didEncounterError: error)
                return
            }
        }
        
        // Create AVPlayerItem
        playerItem = AVPlayerItem(url: mediaURL)
        
        // Create AVPlayer
        avPlayer = AVPlayer(playerItem: playerItem)
        
        // Configure audio session
        setupAudioSession()
        
        trackName = mediaURL.lastPathComponent
        
        // Set up observers
        setupObservers()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        
        do {
            // Conservative settings to avoid conflicts
            try session.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers, .allowAirPlay])
            try session.setActive(true, options: [])
        } catch {
            delegate?.mediaPlayer(self, didEncounterError: error)
        }
        #endif
    }
    
    private func setupObservers() {
        // Observer for playback completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Status observation via NSKeyValueObservation (no manual removeObserver)
        statusObservation = playerItem?.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            guard let self else { return }
            switch item.status {
            case .readyToPlay:
                self.updateDuration()
            case .failed:
                if let error = item.error {
                    self.delegate?.mediaPlayer(self, didEncounterError: error)
                }
            case .unknown:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func setupTimeObserver() {
        // Increase interval to reduce CPU load
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }

            // Debounce to prevent frequent updates
            let newTime = CMTimeGetSeconds(time)
            if abs(newTime - self.currentTime) > 0.1 {
                self.currentTime = newTime
            }
        }
    }
    
    private func removeTimeObserver() {
        if let timeObserver = timeObserver {
            avPlayer?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    private func setupPictureInPicture() {
        #if os(iOS)
        guard let avPlayer = avPlayer else { return }
        let playerLayer = AVPlayerLayer(player: avPlayer)
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
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
        var nowPlayingInfo: [String: Any] = [:]
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = avPlayer?.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateDuration() {
        guard let playerItem = playerItem else { return }
        duration = CMTimeGetSeconds(playerItem.duration)
        setupNowPlaying()
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        delegate?.mediaPlayerDidFinishPlaying(self)
    }
}

// MARK: - AVPictureInPictureControllerDelegate

#if os(iOS)
extension VideoPlayer: AVPictureInPictureControllerDelegate {
    nonisolated public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Task { @MainActor in
            isPictureInPictureActive = true
        }
    }
    
    nonisolated public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        Task { @MainActor in
            isPictureInPictureActive = false
        }
    }
}
#endif
