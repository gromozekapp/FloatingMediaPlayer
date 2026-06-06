//
//  PerformanceOptimizations.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import Foundation
import SwiftUI
#if os(iOS)
import AVFoundation
#endif

/// Performance optimization utilities.
public struct PerformanceOptimizations {
    
    // MARK: - Debouncing
    
    /// Creates a debounced function to prevent rapid repeated calls.
    /// - Parameters:
    ///   - delay: Delay in seconds.
    ///   - action: Action to perform.
    /// - Returns: Debounced function.
    public static func debounce<T>(
        delay: TimeInterval,
        action: @escaping (T) -> Void
    ) -> (T) -> Void {
        var workItem: DispatchWorkItem?
        
        return { value in
            workItem?.cancel()
            workItem = DispatchWorkItem {
                action(value)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }
    
    /// Creates a throttled function to limit call frequency.
    /// - Parameters:
    ///   - interval: Minimum interval between calls in seconds.
    ///   - action: Action to perform.
    /// - Returns: Throttled function.
    public static func throttle<T>(
        interval: TimeInterval,
        action: @escaping (T) -> Void
    ) -> (T) -> Void {
        var lastExecutionTime: Date = Date.distantPast
        
        return { value in
            let now = Date()
            if now.timeIntervalSince(lastExecutionTime) >= interval {
                lastExecutionTime = now
                action(value)
            }
        }
    }
}

// MARK: - Animation Utilities

/// SwiftUI animation optimization utilities.
public struct AnimationOptimizations {
    
    /// Safe animation with debouncing support.
    /// - Parameters:
    ///   - animation: Animation to apply.
    ///   - delay: Delay before applying the animation.
    ///   - action: Action to animate.
    public static func safeAnimation<T>(
        _ animation: Animation,
        delay: TimeInterval = 0.1,
        action: @escaping () -> T
    ) -> T {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                withAnimation(animation) {
                    _ = action()
                }
            }
            return action()
        }
        
        return withAnimation(animation) {
            action()
        }
    }
    
    /// Optimized drag animation.
    public static let optimizedDragAnimation = Animation.easeInOut(duration: 0.2)
    
    /// Optimized size change animation.
    public static let optimizedSizeAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// Optimized controls show/hide animation.
    public static let optimizedControlsAnimation = Animation.easeOut(duration: 0.3)
}

// MARK: - Memory Management

/// Memory management utilities.
public struct MemoryOptimizations {
    
    /// Safely invalidates and clears a timer.
    /// - Parameter timer: Timer to clean up.
    public static func safeTimerCleanup(_ timer: inout Timer?) {
        timer?.invalidate()
        timer = nil
    }
    
    /// Safely removes a time observer.
    /// - Parameters:
    ///   - observer: Observer to remove.
    ///   - object: Observed object.
    public static func safeObserverCleanup(_ observer: inout Any?, from object: AnyObject?) {
        #if os(iOS)
        if let timeObserver = observer as? AnyObject,
           let avPlayer = object as? AVPlayer {
            avPlayer.removeTimeObserver(timeObserver)
        }
        #endif
        observer = nil
    }
}

// MARK: - Audio Session Management

/// Audio session utilities.
public struct AudioSessionOptimizations {
    
    #if os(iOS)
    /// Conservative audio session options.
    public static let conservativeAudioOptions: AVAudioSession.CategoryOptions = [
        .mixWithOthers,
        .allowAirPlay
    ]
    
    /// Safely activates an audio session.
    /// - Parameters:
    ///   - session: Audio session.
    ///   - category: Session category.
    ///   - mode: Session mode.
    ///   - options: Session options.
    /// - Returns: Whether activation succeeded.
    public static func safeActivateSession(
        _ session: AVAudioSession,
        category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) -> Bool {
        do {
            try session.setCategory(category, mode: mode, options: options)
            try session.setActive(true, options: [])
            return true
        } catch {
            #if DEBUG
            print("Audio session activation failed: \(error)")
            #endif
            return false
        }
    }
    #else
    /// Audio session is not used on macOS.
    public static let conservativeAudioOptions: [String] = []
    
    /// No-op on macOS; always returns true.
    public static func safeActivateSession(
        _ session: Any,
        category: Any,
        mode: Any,
        options: Any
    ) -> Bool {
        return true
    }
    #endif
}
