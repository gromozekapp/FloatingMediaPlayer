//
//  FloatingMediaPlayer.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import SwiftUI

// MARK: - Public API

/// Основной компонент плавающего медиа плеера
@available(iOS 15.0, macOS 12.0, *)
public typealias FloatingPlayer = FloatingVideoPlayerView

// MARK: - Re-exports

// Основные компоненты
@available(iOS 15.0, macOS 12.0, *)
public typealias FloatingVideoPlayer = FloatingVideoPlayerView

// Компоненты с прогресс-баром
@available(iOS 15.0, macOS 12.0, *)
public typealias FloatingPlayerWithProgressBar = FloatingPlayerWithProgress

// Конфигурация
@available(iOS 15.0, macOS 12.0, *)
public typealias PlayerConfiguration = FloatingPlayerConfiguration

// Утилиты
public typealias MediaDetector = MediaTypeDetector
public typealias PlayerFactory = MediaPlayerFactory

// Оптимизации производительности
public typealias PerformanceUtils = PerformanceOptimizations
public typealias AnimationUtils = AnimationOptimizations
public typealias MemoryUtils = MemoryOptimizations
public typealias AudioUtils = AudioSessionOptimizations

// MARK: - Public Types

// Экспорт основных типов для удобства использования
@available(iOS 15.0, macOS 12.0, *)
public typealias MediaPlayer = any MediaPlayerProtocol

// Экспорт делегатов
@available(iOS 15.0, macOS 12.0, *)
public typealias PlayerDelegate = MediaPlayerDelegate
