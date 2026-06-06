# FloatingMediaPlayer

Swift Package для **плавающих видео- и аудио-плееров** в SwiftUI — круглый mini-player в духе Telegram, с поддержкой аудио, перемоткой через progress ring и гибкой настройкой UI.

![Version](https://img.shields.io/badge/version-1.3.5-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2016%2B%20%7C%20macOS%2013%2B-lightgrey.svg)
![Swift](https://img.shields.io/badge/swift-5.9%2B-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![CI](https://github.com/gromozekapp/FloatingMediaPlayer/actions/workflows/ci.yml/badge.svg)

[English README](README.md) · [Changelog](CHANGELOG.md)

## Возможности

- Видео и аудио — автоопределение типа (AVFoundation / AVPlayer)
- Перетаскиваемое плавающее окно
- Круговой progress ring с перемоткой
- Элементы управления с автоскрытием
- Пресеты конфигурации: `.minimal`, `.full`, `.compact`
- Архитектура: протоколы, делегаты, фабрика, SPM
- Unit-тесты

## Требования

- iOS 16.0+ / macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Поддержка платформ

| Функция | iOS | macOS |
|---------|-----|-------|
| Плавающее видео | ✅ | ✅ |
| Плавающее аудио | ✅ | ✅ |
| Remote video (HTTPS) | ✅ | ✅ |
| Remote audio | ❌ | ❌ |
| Picture-in-Picture | ✅ | — |

Remote audio — только локальные файлы (`AVAudioPlayer` не поддерживает streaming).

## Установка

```swift
dependencies: [
    .package(url: "https://github.com/gromozekapp/FloatingMediaPlayer.git", from: "1.3.5")
]
```

## Быстрый старт

```swift
import FloatingMediaPlayer
import SwiftUI

struct ContentView: View {
    var body: some View {
        YourContent()
            .overlay {
                FloatingVideoPlayerView(mediaURL: mediaURL, configuration: .full)
            }
    }
}
```

## Тесты

```bash
swift test
```

## Демо и релиз

- Инструкция по GIF: [Docs/README.md](Docs/README.md)
- Release notes v1.3.5: [Docs/RELEASE_NOTES_v1.3.5.md](Docs/RELEASE_NOTES_v1.3.5.md)

## Лицензия

MIT — см. [LICENSE](LICENSE).
