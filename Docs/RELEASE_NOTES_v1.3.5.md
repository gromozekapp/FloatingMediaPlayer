# FloatingMediaPlayer v1.3.5

> Copy this into the GitHub release description when publishing.

## Highlights

Draggable floating video and audio player for SwiftUI — Telegram-inspired circular mini-player with seekable progress ring.

## What's included

- `FloatingVideoPlayerView` — main SwiftUI component
- Video (AVPlayer) and audio (AVAudioPlayer) with automatic type detection
- Circular progress ring with drag-to-seek
- Configuration presets: `.minimal`, `.full`, `.compact`
- `MediaPlayerDelegate` for playback and interaction events
- `MediaPlayerFactory` for programmatic player creation
- Performance utilities (debounce, safe animations)
- 15 unit tests

## Requirements

- iOS 16.0+ / macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/gromozekapp/FloatingMediaPlayer.git", from: "1.3.5")
]
```

## Quick start

```swift
import FloatingMediaPlayer
import SwiftUI

struct ContentView: View {
    let mediaURL: URL

    var body: some View {
        YourContent()
            .overlay {
                FloatingVideoPlayerView(mediaURL: mediaURL, configuration: .full)
            }
    }
}
```

## Changes in v1.3.5

- Added `autoPlayOnAppear` configuration option
- Refactored player components and configuration handling
- Remote video URLs supported (HTTPS streams via AVPlayer)
- macOS video rendering via `AVPlayerLayer`
- Public release preparation: CI, docs, LICENSE fix

## Full changelog

See [CHANGELOG.md](../CHANGELOG.md).
