//
//  MediaPlayerFactory.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import Foundation

/// Фабрика для создания медиа плееров
public enum MediaPlayerFactory {
    
    /// Создает подходящий медиа плеер для указанного URL
    /// - Parameters:
    ///   - url: URL медиа файла
    ///   - delegate: Делегат для получения событий
    /// - Returns: Созданный медиа плеер или nil, если формат не поддерживается
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
    
    /// Создает видео плеер
    /// - Parameters:
    ///   - url: URL видео файла
    ///   - delegate: Делегат для получения событий
    /// - Returns: Созданный видео плеер
    public static func createVideoPlayer(
        for url: URL,
        delegate: MediaPlayerDelegate? = nil
    ) -> VideoPlayer {
        return VideoPlayer(videoFileURL: url, delegate: delegate)
    }
    
    /// Создает аудио плеер
    /// - Parameters:
    ///   - url: URL аудио файла
    ///   - delegate: Делегат для получения событий
    /// - Returns: Созданный аудио плеер
    public static func createAudioPlayer(
        for url: URL,
        delegate: MediaPlayerDelegate? = nil
    ) -> AudioPlayer {
        return AudioPlayer(audioFileURL: url, delegate: delegate)
    }
}
