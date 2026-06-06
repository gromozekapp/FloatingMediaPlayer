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

/// Протокол для всех типов медиа плееров
public protocol MediaPlayerProtocol: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    /// URL медиа файла
    var mediaURL: URL { get }
    
    /// Длительность в секундах
    var duration: Double { get }
    
    /// Текущее время воспроизведения в секундах
    var currentTime: Double { get }
    
    /// Состояние воспроизведения
    var isPlaying: Bool { get }
    
    /// Название трека
    var trackName: String { get }
    
    /// Позиция плавающего плеера на экране
    var floatingPosition: CGPoint { get set }
    
    /// Размер плавающего плеера
    var floatingSize: CGFloat { get set }
    
    /// Начать воспроизведение
    func play()
    
    /// Приостановить воспроизведение
    func pause()
    
    /// Остановить воспроизведение
    func stop()
    
    /// Установить время воспроизведения
    func seek(to time: Double)
    
    /// Перемотать вперед на 15 секунд
    func skipForward()
    
    /// Перемотать назад на 15 секунд
    func skipBackward()
    
    /// Обновить позицию плавающего плеера
    @MainActor func updateFloatingPosition(_ position: CGPoint)
    
    /// Обновить размер плавающего плеера
    @MainActor func updateFloatingSize(_ size: CGFloat)
}

// MARK: - Media Player Delegate

/// Делегат для получения событий от медиа плеера
public protocol MediaPlayerDelegate: AnyObject {
    /// Плеер начал воспроизведение
    func mediaPlayerDidStartPlaying(_ player: any MediaPlayerProtocol)
    
    /// Плеер закончил воспроизведение
    func mediaPlayerDidFinishPlaying(_ player: any MediaPlayerProtocol)
    
    /// Плеер изменил позицию на экране
    func mediaPlayerDidChangePosition(_ player: any MediaPlayerProtocol, position: CGPoint)
    
    /// Плеер изменил размер
    func mediaPlayerDidChangeSize(_ player: any MediaPlayerProtocol, size: CGFloat)
    
    /// Произошла ошибка воспроизведения
    func mediaPlayer(_ player: any MediaPlayerProtocol, didEncounterError error: Error)
}

// MARK: - Media Type Detection

/// Утилита для определения типа медиа файла
public struct MediaTypeDetector {
    
    /// Поддерживаемые видео форматы
    public static let supportedVideoFormats = ["mp4", "mov", "avi", "mkv", "m4v", "3gp", "webm"]
    
    /// Поддерживаемые аудио форматы
    public static let supportedAudioFormats = ["mp3", "m4a", "wav", "aac", "flac", "ogg"]
    
    /// Определяет тип медиа файла по расширению
    /// - Parameter url: URL файла
    /// - Returns: Тип медиа файла
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

/// Типы медиа файлов
public enum MediaType {
    case video
    case audio
    case unknown
}
