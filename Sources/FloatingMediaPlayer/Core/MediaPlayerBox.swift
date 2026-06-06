import Combine
import Foundation

/// Wrapper that lets SwiftUI observe `any MediaPlayerProtocol`.
///
/// SwiftUI cannot use `@ObservedObject` directly with existential types (`any ...`),
/// so we forward `objectWillChange` from the concrete player implementation.
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
