import Combine
import Foundation

/// Обертка, позволяющая SwiftUI наблюдать `any MediaPlayerProtocol`.
///
/// SwiftUI не умеет напрямую использовать `@ObservedObject` с existential типом (`any ...`),
/// поэтому мы форвардим `objectWillChange` от конкретной реализации плеера.
final class MediaPlayerBox: ObservableObject {
    @Published var player: (any MediaPlayerProtocol)? {
        didSet { bindToPlayer() }
    }

    private var cancellable: AnyCancellable?

    init(player: (any MediaPlayerProtocol)? = nil) {
        self.player = player
        bindToPlayer()
    }

    private func bindToPlayer() {
        cancellable = nil
        guard let player else { return }

        cancellable = player.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }
}
