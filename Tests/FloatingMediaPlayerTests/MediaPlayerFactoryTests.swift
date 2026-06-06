//
//  MediaPlayerFactoryTests.swift
//  FloatingMediaPlayerTests
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import XCTest
@testable import FloatingMediaPlayer

@MainActor
final class MediaPlayerFactoryTests: XCTestCase {
    
    func testCreateVideoPlayer() {
        let videoURL = URL(fileURLWithPath: "/test/video.mp4")
        let player = MediaPlayerFactory.createVideoPlayer(for: videoURL)
        
        XCTAssertTrue(player is VideoPlayer)
        XCTAssertEqual(player.mediaURL, videoURL)
    }
    
    func testCreateAudioPlayer() {
        let audioURL = URL(fileURLWithPath: "/test/audio.mp3")
        let player = MediaPlayerFactory.createAudioPlayer(for: audioURL)
        
        XCTAssertTrue(player is AudioPlayer)
        XCTAssertEqual(player.mediaURL, audioURL)
    }
    
    func testCreatePlayerForVideo() {
        let videoURL = URL(fileURLWithPath: "/test/video.mp4")
        let player = MediaPlayerFactory.createPlayer(for: videoURL)
        
        XCTAssertNotNil(player)
        XCTAssertTrue(player is VideoPlayer)
        XCTAssertEqual(player?.mediaURL, videoURL)
    }
    
    func testCreatePlayerForAudio() {
        let audioURL = URL(fileURLWithPath: "/test/audio.mp3")
        let player = MediaPlayerFactory.createPlayer(for: audioURL)
        
        XCTAssertNotNil(player)
        XCTAssertTrue(player is AudioPlayer)
        XCTAssertEqual(player?.mediaURL, audioURL)
    }
    
    func testCreatePlayerForUnknownFormat() {
        let unknownURL = URL(fileURLWithPath: "/test/document.pdf")
        let player = MediaPlayerFactory.createPlayer(for: unknownURL)
        
        XCTAssertNil(player)
    }
    
    func testCreatePlayerWithDelegate() {
        let delegate = MockMediaPlayerDelegate()
        let videoURL = URL(fileURLWithPath: "/test/video.mp4")
        let player = MediaPlayerFactory.createPlayer(for: videoURL, delegate: delegate)
        
        XCTAssertNotNil(player)
        XCTAssertTrue(player is VideoPlayer)
    }
}

// MARK: - Mock Delegate

class MockMediaPlayerDelegate: MediaPlayerDelegate {
    var didStartPlaying = false
    var didFinishPlaying = false
    var positionChanged = false
    var sizeChanged = false
    var errorEncountered = false
    
    func mediaPlayerDidStartPlaying(_ player: any MediaPlayerProtocol) {
        didStartPlaying = true
    }
    
    func mediaPlayerDidFinishPlaying(_ player: any MediaPlayerProtocol) {
        didFinishPlaying = true
    }
    
    func mediaPlayerDidChangePosition(_ player: any MediaPlayerProtocol, position: CGPoint) {
        positionChanged = true
    }
    
    func mediaPlayerDidChangeSize(_ player: any MediaPlayerProtocol, size: CGFloat) {
        sizeChanged = true
    }
    
    func mediaPlayer(_ player: any MediaPlayerProtocol, didEncounterError error: Error) {
        errorEncountered = true
    }
}
