//
//  MediaPlayerProtocol.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Media Player Protocol

/// Protocol for all media player types.
public protocol MediaPlayerProtocol: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    /// Media file URL.
    var mediaURL: URL { get }
    
    /// Duration in seconds.
    var duration: Double { get }
    
    /// Current playback time in seconds.
    var currentTime: Double { get }
    
    /// Playback state.
    var isPlaying: Bool { get }
    
    /// Track title.
    var trackName: String { get }
    
    /// Floating player position on screen.
    var floatingPosition: CGPoint { get set }
    
    /// Floating player size.
    var floatingSize: CGFloat { get set }
    
    /// Start playback.
    func play()
    
    /// Pause playback.
    func pause()
    
    /// Stop playback.
    func stop()
    
    /// Seek to the given time.
    func seek(to time: Double)
    
    /// Skip forward 15 seconds.
    func skipForward()
    
    /// Skip backward 15 seconds.
    func skipBackward()
    
    /// Update floating player position.
    @MainActor func updateFloatingPosition(_ position: CGPoint)
    
    /// Update floating player size.
    @MainActor func updateFloatingSize(_ size: CGFloat)
}

// MARK: - Media Player Delegate

/// Delegate for media player events.
public protocol MediaPlayerDelegate: AnyObject {
    /// Playback started.
    func mediaPlayerDidStartPlaying(_ player: any MediaPlayerProtocol)
    
    /// Playback finished.
    func mediaPlayerDidFinishPlaying(_ player: any MediaPlayerProtocol)
    
    /// Player position on screen changed.
    func mediaPlayerDidChangePosition(_ player: any MediaPlayerProtocol, position: CGPoint)
    
    /// Player size changed.
    func mediaPlayerDidChangeSize(_ player: any MediaPlayerProtocol, size: CGFloat)
    
    /// Playback error occurred.
    func mediaPlayer(_ player: any MediaPlayerProtocol, didEncounterError error: Error)
}

// MARK: - Media Type Detection

/// Utility for detecting media file type by extension.
public struct MediaTypeDetector {
    
    /// Supported video formats.
    public static let supportedVideoFormats = ["mp4", "mov", "avi", "mkv", "m4v", "3gp", "webm"]
    
    /// Supported audio formats.
    public static let supportedAudioFormats = ["mp3", "m4a", "wav", "aac", "flac", "ogg"]
    
    /// Detects media type from file extension.
    /// - Parameter url: File URL.
    /// - Returns: Detected media type.
    public static func detectMediaType(from url: URL) -> MediaType {
        let fileExtension = url.pathExtension.lowercased()
        
        if supportedVideoFormats.contains(fileExtension) {
            return .video
        } else if supportedAudioFormats.contains(fileExtension) {
            return .audio
        } else {
            return .unknown
        }
    }
}

// MARK: - Media Type Enum

/// Media file types.
public enum MediaType {
    case video
    case audio
    case unknown
}
