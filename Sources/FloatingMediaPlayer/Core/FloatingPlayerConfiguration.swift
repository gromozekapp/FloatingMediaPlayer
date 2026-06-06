//
//  FloatingPlayerConfiguration.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import SwiftUI

/// Конфигурация для плавающего медиа плеера
public struct FloatingPlayerConfiguration: Equatable {
    
    // MARK: - Position & Size
    
    /// Позиция по умолчанию на экране
    public let defaultPosition: CGPoint
    
    /// Размер плеера по умолчанию
    public let defaultSize: CGFloat
    
    /// Минимальный размер плеера
    public let minimumSize: CGFloat
    
    /// Максимальный размер плеера
    public let maximumSize: CGFloat
    
    // MARK: - Controls
    
    /// Показывать элементы управления
    public let showControls: Bool
    
    /// Время до скрытия элементов управления (в секундах)
    public let controlsTimeout: TimeInterval
    
    // MARK: - Animation
    
    /// Длительность анимации появления/скрытия элементов управления
    public let animationDuration: Double
    
    /// Длительность анимации перетаскивания
    public let dragAnimationDuration: Double
    
    /// Тип анимации для перетаскивания
    public let dragAnimationType: Animation
    
    // MARK: - Visual
    
    /// Цвет границы плеера
    public let borderColor: Color
    
    /// Ширина границы
    public let borderWidth: CGFloat
    
    /// Цвет тени
    public let shadowColor: Color
    
    /// Радиус тени
    public let shadowRadius: CGFloat
    
    /// Смещение тени
    public let shadowOffset: CGSize
    
    /// Цвет фона для аудио плеера
    public let audioBackgroundColors: [Color]
    
    /// Цвет иконки
    public let iconColor: Color
    
    // MARK: - Behavior
    
    /// Разрешить перетаскивание
    public let allowDragging: Bool
    
    /// Разрешить изменение размера жестами
    public let allowResizing: Bool
    
    /// Автоматически определять тип медиа
    public let autoDetectMediaType: Bool
    
    /// Начать воспроизведение сразу после появления плеера (например в оверлее)
    public let autoPlayOnAppear: Bool
    
    // MARK: - Initialization
    
    public init(
        defaultPosition: CGPoint = CGPoint(x: 300, y: 500),
        defaultSize: CGFloat = 160,
        minimumSize: CGFloat = 60,
        maximumSize: CGFloat = 200,
        showControls: Bool = true,
        controlsTimeout: TimeInterval = 3.0,
        animationDuration: Double = 0.3,
        dragAnimationDuration: Double = 0.5,
        dragAnimationType: Animation = .spring(response: 0.5, dampingFraction: 0.8),
        borderColor: Color = .blue,
        borderWidth: CGFloat = 2,
        shadowColor: Color = .black.opacity(0.3),
        shadowRadius: CGFloat = 10,
        shadowOffset: CGSize = CGSize(width: 0, height: 5),
        audioBackgroundColors: [Color] = [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
        iconColor: Color = .white,
        allowDragging: Bool = true,
        allowResizing: Bool = false,
        autoDetectMediaType: Bool = true,
        autoPlayOnAppear: Bool = false
    ) {
        self.defaultPosition = defaultPosition
        self.defaultSize = defaultSize
        self.minimumSize = minimumSize
        self.maximumSize = maximumSize
        self.showControls = showControls
        self.controlsTimeout = controlsTimeout
        self.animationDuration = animationDuration
        self.dragAnimationDuration = dragAnimationDuration
        self.dragAnimationType = dragAnimationType
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.audioBackgroundColors = audioBackgroundColors
        self.iconColor = iconColor
        self.allowDragging = allowDragging
        self.allowResizing = allowResizing
        self.autoDetectMediaType = autoDetectMediaType
        self.autoPlayOnAppear = autoPlayOnAppear
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: FloatingPlayerConfiguration, rhs: FloatingPlayerConfiguration) -> Bool {
        return lhs.defaultPosition == rhs.defaultPosition &&
               lhs.defaultSize == rhs.defaultSize &&
               lhs.minimumSize == rhs.minimumSize &&
               lhs.maximumSize == rhs.maximumSize &&
               lhs.showControls == rhs.showControls &&
               lhs.controlsTimeout == rhs.controlsTimeout &&
               lhs.allowDragging == rhs.allowDragging &&
               lhs.allowResizing == rhs.allowResizing &&
               lhs.autoDetectMediaType == rhs.autoDetectMediaType &&
               lhs.autoPlayOnAppear == rhs.autoPlayOnAppear
    }
}

// MARK: - Preset Configurations

public extension FloatingPlayerConfiguration {
    
    /// Минималистичная конфигурация
    static let minimal = FloatingPlayerConfiguration(
        defaultPosition: CGPoint(x: 300, y: 500),
        defaultSize: 120,
        showControls: false,
        controlsTimeout: 0,
        borderColor: .clear,
        borderWidth: 0,
        shadowRadius: 5,
        allowDragging: true
    )
    
    /// Конфигурация с полным функционалом
    static let full = FloatingPlayerConfiguration(
        defaultPosition: CGPoint(x: 300, y: 500),
        defaultSize: 180,
        showControls: true,
        controlsTimeout: 5.0,
        animationDuration: 0.4,
        borderColor: .blue,
        borderWidth: 3,
        shadowRadius: 15,
        allowDragging: true,
        allowResizing: true
    )
    
    /// Конфигурация для компактного отображения
    static let compact = FloatingPlayerConfiguration(
        defaultPosition: CGPoint(x: 300, y: 500),
        defaultSize: 80,
        minimumSize: 60,
        maximumSize: 120,
        showControls: true,
        controlsTimeout: 2.0,
        borderWidth: 1,
        shadowRadius: 5,
        allowDragging: true
    )
}
