//
//  CircularProgressRing.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 18.09.25.
//

import SwiftUI

/// Circular progress ring with playback time display
public struct CircularProgressRing: View {
    let progress: Double // 0.0 - 1.0
    let currentTime: TimeInterval
    let duration: TimeInterval
    let size: CGFloat
    let onProgressChanged: ((Double) -> Void)?
    
    public init(
        progress: Double,
        currentTime: TimeInterval,
        duration: TimeInterval,
        size: CGFloat,
        onProgressChanged: ((Double) -> Void)? = nil
    ) {
        self.progress = progress
        self.currentTime = currentTime
        self.duration = duration
        self.size = size
        self.onProgressChanged = onProgressChanged
    }
    
    private var progressAngle: Double {
        progress * 360.0
    }
    
    private var formattedTime: String {
        let current = Int(currentTime)
        let total = Int(duration)
        let currentMinutes = current / 60
        let currentSeconds = current % 60
        let totalMinutes = total / 60
        let totalSeconds = total % 60
        
        return String(format: "%d:%02d / %d:%02d",
                     currentMinutes, currentSeconds,
                     totalMinutes, totalSeconds)
    }
    
    private func safeProgressUpdate(_ newProgress: Double) {
        // Validate progress value
        guard newProgress >= 0 && newProgress <= 1 else { return }
        guard !newProgress.isNaN && !newProgress.isInfinite else { return }
        
        onProgressChanged?(newProgress)
    }
    
    public var body: some View {
        ZStack {
            // Background ring (thinner and more transparent)
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 3)
                .frame(width: size, height: size)
            
            // Progress ring at maximum radius
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white.opacity(0.9),
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90)) // Start from the top
                .overlay(
                    // Control handle at the progress end
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(y: -size/2)
                        .rotationEffect(.degrees(progress * 360))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Compute angle from drag position
                                    let center = CGPoint(x: size/2, y: size/2)
                                    let angle = atan2(value.location.x - center.x, center.y - value.location.y)
                                    let normalizedAngle = (angle + .pi) / (2 * .pi)
                                    let newProgress = max(0, min(1, normalizedAngle))
                                    
                                    // Safe progress validation
                                    safeProgressUpdate(newProgress)
                                }
                        )
                )
            
            // Time label at the top of the ring
            if size > 80 {
                Text(formattedTime)
                    .font(.system(size: size * 0.06, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .offset(y: -size * 0.6) // Position at the top of the ring
            }
        }
        .background(
            // Semi-transparent background for better visibility
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: size, height: size)
        )
    }
}

#Preview {
    CircularProgressRing(
        progress: 0.6,
        currentTime: 72.0,
        duration: 120.0,
        size: 120
    )
    .background(Color.gray)
}
