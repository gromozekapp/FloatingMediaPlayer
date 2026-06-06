//
//  MediaTypeDetectorTests.swift
//  FloatingMediaPlayerTests
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import XCTest
@testable import FloatingMediaPlayer

final class MediaTypeDetectorTests: XCTestCase {
    
    func testVideoFormatDetection() {
        let testCases: [(String, MediaType)] = [
            ("video.mp4", .video),
            ("movie.mov", .video),
            ("clip.avi", .video),
            ("film.mkv", .video),
            ("content.m4v", .video),
            ("phone.3gp", .video),
            ("web.webm", .video)
        ]
        
        for (filename, expectedType) in testCases {
            let url = URL(fileURLWithPath: "/path/to/\(filename)")
            let detectedType = MediaTypeDetector.detectMediaType(from: url)
            XCTAssertEqual(detectedType, expectedType, "Failed to detect video type for \(filename)")
        }
    }
    
    func testAudioFormatDetection() {
        let testCases: [(String, MediaType)] = [
            ("song.mp3", .audio),
            ("music.m4a", .audio),
            ("sound.wav", .audio),
            ("track.aac", .audio),
            ("lossless.flac", .audio),
            ("stream.ogg", .audio)
        ]
        
        for (filename, expectedType) in testCases {
            let url = URL(fileURLWithPath: "/path/to/\(filename)")
            let detectedType = MediaTypeDetector.detectMediaType(from: url)
            XCTAssertEqual(detectedType, expectedType, "Failed to detect audio type for \(filename)")
        }
    }
    
    func testUnknownFormatDetection() {
        let testCases = [
            "document.pdf",
            "image.jpg",
            "text.txt",
            "archive.zip"
        ]
        
        for filename in testCases {
            let url = URL(fileURLWithPath: "/path/to/\(filename)")
            let detectedType = MediaTypeDetector.detectMediaType(from: url)
            XCTAssertEqual(detectedType, .unknown, "Should detect unknown type for \(filename)")
        }
    }
    
    func testCaseInsensitiveDetection() {
        let testCases: [(String, MediaType)] = [
            ("VIDEO.MP4", .video),
            ("Movie.MOV", .video),
            ("SONG.MP3", .audio),
            ("Music.M4A", .audio)
        ]
        
        for (filename, expectedType) in testCases {
            let url = URL(fileURLWithPath: "/path/to/\(filename)")
            let detectedType = MediaTypeDetector.detectMediaType(from: url)
            XCTAssertEqual(detectedType, expectedType, "Case insensitive detection failed for \(filename)")
        }
    }
}
