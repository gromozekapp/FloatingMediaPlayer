//
//  MediaPlayerFactory.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import Foundation

/// Factory for creating media players.
public enum MediaPlayerFactory {
    
    /// Creates the appropriate media player for the given URL.
    /// - Parameters:
    ///   - url: Media file URL.
    ///   - delegate: Optional event delegate.
    /// - Returns: Created player, or `nil` if the format is unsupported.
    public static func createPlayer(
        for url: URL,
        delegate: MediaPlayerDelegate? = nil
    ) -> (any MediaPlayerProtocol)? {
        let mediaType = MediaTypeDetector.detectMediaType(from: url)
        
        switch mediaType {
        case .video:
            return VideoPlayer(videoFileURL: url, delegate: delegate)
        case .audio:
            return AudioPlayer(audioFileURL: url, delegate: delegate)
        case .unknown:
            return nil
        }
    }
    
    /// Creates a video player.
    /// - Parameters:
    ///   - url: Video file URL.
    ///   - delegate: Optional event delegate.
    /// - Returns: Created video player.
    public static func createVideoPlayer(
        for url: URL,
        delegate: MediaPlayerDelegate? = nil
    ) -> VideoPlayer {
        return VideoPlayer(videoFileURL: url, delegate: delegate)
    }
    
    /// Creates an audio player.
    /// - Parameters:
    ///   - url: Audio file URL.
    ///   - delegate: Optional event delegate.
    /// - Returns: Created audio player.
    public static func createAudioPlayer(
        for url: URL,
        delegate: MediaPlayerDelegate? = nil
    ) -> AudioPlayer {
        return AudioPlayer(audioFileURL: url, delegate: delegate)
    }
}
