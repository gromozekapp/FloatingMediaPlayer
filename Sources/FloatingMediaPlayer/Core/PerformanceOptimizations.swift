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

/// Утилиты для оптимизации производительности
public struct PerformanceOptimizations {
    
    // MARK: - Debouncing
    
    /// Создает debounced функцию для предотвращения частых вызовов
    /// - Parameters:
    ///   - delay: Задержка в секундах
    ///   - action: Действие для выполнения
    /// - Returns: Debounced функция
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
    
    /// Создает throttled функцию для ограничения частоты вызовов
    /// - Parameters:
    ///   - interval: Интервал между вызовами в секундах
    ///   - action: Действие для выполнения
    /// - Returns: Throttled функция
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

/// Утилиты для оптимизации анимаций SwiftUI
public struct AnimationOptimizations {
    
    /// Безопасная анимация с debouncing
    /// - Parameters:
    ///   - animation: Анимация для применения
    ///   - delay: Задержка перед применением анимации
    ///   - action: Действие для анимации
    public static func safeAnimation<T>(
        _ animation: Animation,
        delay: TimeInterval = 0.1,
        action: @escaping () -> T
    ) -> T {
        // Проверяем, что мы на главном потоке
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
    
    /// Оптимизированная анимация для перетаскивания
    public static let optimizedDragAnimation = Animation.easeInOut(duration: 0.2)
    
    /// Оптимизированная анимация для изменения размера
    public static let optimizedSizeAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// Оптимизированная анимация для показа/скрытия контролов
    public static let optimizedControlsAnimation = Animation.easeOut(duration: 0.3)
}

// MARK: - Memory Management

/// Утилиты для управления памятью
public struct MemoryOptimizations {
    
    /// Безопасная очистка таймера
    /// - Parameter timer: Таймер для очистки
    public static func safeTimerCleanup(_ timer: inout Timer?) {
        timer?.invalidate()
        timer = nil
    }
    
    /// Безопасная очистка наблюдателя
    /// - Parameters:
    ///   - observer: Наблюдатель для удаления
    ///   - object: Объект, за которым наблюдают
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

/// Утилиты для управления аудио сессией
public struct AudioSessionOptimizations {
    
    #if os(iOS)
    /// Консервативные настройки аудио сессии
    public static let conservativeAudioOptions: AVAudioSession.CategoryOptions = [
        .mixWithOthers,
        .allowAirPlay
    ]
    
    /// Безопасная активация аудио сессии
    /// - Parameters:
    ///   - session: Аудио сессия
    ///   - category: Категория сессии
    ///   - mode: Режим сессии
    ///   - options: Опции сессии
    /// - Returns: Успешность операции
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
    /// Для macOS и других платформ аудио сессия не нужна
    public static let conservativeAudioOptions: [String] = []
    
    /// Для macOS и других платформ всегда возвращаем true
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
