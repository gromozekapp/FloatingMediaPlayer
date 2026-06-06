//
//  FloatingMediaPlayer.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import SwiftUI

// MARK: - Public API

/// Main floating media player component
@available(iOS 16.0, macOS 13.0, *)
public typealias FloatingPlayer = FloatingVideoPlayerView

// MARK: - Re-exports

// Core components
@available(iOS 16.0, macOS 13.0, *)
public typealias FloatingVideoPlayer = FloatingVideoPlayerView

// Progress ring components
@available(iOS 16.0, macOS 13.0, *)
public typealias FloatingPlayerWithProgressBar = FloatingPlayerWithProgress

// Configuration
@available(iOS 16.0, macOS 13.0, *)
public typealias PlayerConfiguration = FloatingPlayerConfiguration

// Utilities
public typealias MediaDetector = MediaTypeDetector
public typealias PlayerFactory = MediaPlayerFactory

// Performance optimizations
public typealias PerformanceUtils = PerformanceOptimizations
public typealias AnimationUtils = AnimationOptimizations
public typealias MemoryUtils = MemoryOptimizations
public typealias AudioUtils = AudioSessionOptimizations

// MARK: - Public Types

// Re-export core types for convenience
@available(iOS 16.0, macOS 13.0, *)
public typealias MediaPlayer = any MediaPlayerProtocol

// Delegate re-exports
@available(iOS 16.0, macOS 13.0, *)
public typealias PlayerDelegate = MediaPlayerDelegate
