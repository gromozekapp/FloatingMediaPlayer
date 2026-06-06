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
- iOS example app in `Examples/FMP_EXAMPLE/`

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

## Full changelog

See [CHANGELOG.md](https://github.com/gromozekapp/FloatingMediaPlayer/blob/main/CHANGELOG.md).
