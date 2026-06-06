# Changelog

All notable changes to this project are documented in this file.

## [1.3.5] - 2025-06-06

### Added
- `autoPlayOnAppear` configuration option

### Changed
- Refactored player components and configuration handling
- macOS video rendering via `AVPlayerLayer` (replaces placeholder)
- Remote video URLs supported (HTTPS streams via AVPlayer)

### Fixed
- Public release preparation: CI workflow, docs, LICENSE

## [1.3.0] - 2025

### Added
- Circular progress ring with drag-to-seek scrubbing
- Integrated progress ring inside `FloatingVideoPlayerView`
- Real-time sync with AVPlayer / AudioPlayer

### Changed
- Simplified UI — removed redundant progress toggle button
- Increased progress ring line width (3px → 6px)
- Time labels moved to the top of the ring
- Progress ring architecture merged into the main player view

## [1.2.0] - 2025

### Added
- `PerformanceOptimizations` — debouncing and throttling utilities
- `AnimationOptimizations` — safer SwiftUI animations
- `MemoryOptimizations` — timer cleanup helpers
- `AudioSessionOptimizations` — stable audio session handling
- `Equatable` conformance for SwiftUI optimization

### Changed
- Optimized timer update intervals
- Improved resource cleanup in `deinit`
- Improved thread safety with `@MainActor`

### Fixed
- SwiftUI animation conflicts (`AnimatablePair` issues)
- Audio session overload issues
- Memory leak prevention

## [1.1.0] - 2025

### Changed
- UI refactoring and performance fixes
- Concurrency and error handling improvements

## [1.0.0] - 2025

### Added
- Initial release
- `FloatingVideoPlayerView` with video and audio support
- Draggable floating player window
- Configurable UI via `FloatingPlayerConfiguration`
- `MediaPlayerFactory`, delegates, and unit tests

[1.3.5]: https://github.com/gromozekapp/FloatingMediaPlayer/releases/tag/v1.3.5
