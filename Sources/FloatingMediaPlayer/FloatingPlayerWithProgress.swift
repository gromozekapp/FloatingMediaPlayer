//
//  FloatingPlayerWithProgress.swift
//  FloatingMediaPlayer
//
//  Created by Daniil Zolotarev on 18.09.25.
//

import SwiftUI

/// Wrapper for FloatingVideoPlayerView with a circular progress ring
public struct FloatingPlayerWithProgress: View {
    let mediaURL: URL
    let configuration: FloatingPlayerConfiguration?
    let delegate: MediaPlayerDelegate?
    
    public init(
        mediaURL: URL,
        configuration: FloatingPlayerConfiguration? = nil,
        delegate: MediaPlayerDelegate? = nil
    ) {
        self.mediaURL = mediaURL
        self.configuration = configuration
        self.delegate = delegate
    }
    
    public var body: some View {
        FloatingVideoPlayerView(
            mediaURL: mediaURL,
            configuration: configuration ?? .minimal,
            delegate: delegate
        )
    }
}

#Preview {
    FloatingPlayerWithProgress(
        mediaURL: URL(string: "https://example.com/video.mp4")!
    )
    .frame(width: 300, height: 200)
    .background(Color.gray)
}
