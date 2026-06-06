//
//  FloatingPlayerConfiguration.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import SwiftUI

/// Configuration for the floating media player.
public struct FloatingPlayerConfiguration: Equatable {
    
    // MARK: - Position & Size
    
    /// Default on-screen position.
    public let defaultPosition: CGPoint
    
    /// Default player size.
    public let defaultSize: CGFloat
    
    /// Minimum player size.
    public let minimumSize: CGFloat
    
    /// Maximum player size.
    public let maximumSize: CGFloat
    
    // MARK: - Controls
    
    /// Whether to show playback controls.
    public let showControls: Bool
    
    /// Time before controls auto-hide (seconds).
    public let controlsTimeout: TimeInterval
    
    // MARK: - Animation
    
    /// Controls show/hide animation duration.
    public let animationDuration: Double
    
    /// Drag animation duration.
    public let dragAnimationDuration: Double
    
    /// Drag animation type.
    public let dragAnimationType: Animation
    
    // MARK: - Visual
    
    /// Player border color.
    public let borderColor: Color
    
    /// Border width.
    public let borderWidth: CGFloat
    
    /// Shadow color.
    public let shadowColor: Color
    
    /// Shadow radius.
    public let shadowRadius: CGFloat
    
    /// Shadow offset.
    public let shadowOffset: CGSize
    
    /// Audio player background gradient colors.
    public let audioBackgroundColors: [Color]
    
    /// Icon color.
    public let iconColor: Color
    
    // MARK: - Behavior
    
    /// Allow dragging the player.
    public let allowDragging: Bool
    
    /// Allow resizing via gestures.
    public let allowResizing: Bool
    
    /// Automatically detect media type from URL.
    public let autoDetectMediaType: Bool
    
    /// Start playback when the player appears (e.g. in an overlay).
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
    
    /// Minimal configuration.
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
    
    /// Full-featured configuration.
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
    
    /// Compact configuration.
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
