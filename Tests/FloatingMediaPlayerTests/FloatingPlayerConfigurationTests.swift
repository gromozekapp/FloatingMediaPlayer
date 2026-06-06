//
//  FloatingPlayerConfigurationTests.swift
//  FloatingMediaPlayerTests
//
//  Created by Daniil Zolotarev on 17.02.25.
//

import XCTest
@testable import FloatingMediaPlayer
import SwiftUI

final class FloatingPlayerConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration() {
        let config = FloatingPlayerConfiguration()
        
        XCTAssertEqual(config.defaultPosition, CGPoint(x: 300, y: 500))
        XCTAssertEqual(config.defaultSize, 160)
        XCTAssertEqual(config.minimumSize, 60)
        XCTAssertEqual(config.maximumSize, 200)
        XCTAssertTrue(config.showControls)
        XCTAssertEqual(config.controlsTimeout, 3.0)
        XCTAssertEqual(config.animationDuration, 0.3)
        XCTAssertTrue(config.allowDragging)
        XCTAssertFalse(config.allowResizing)
        XCTAssertTrue(config.autoDetectMediaType)
        XCTAssertFalse(config.autoPlayOnAppear)
    }
    
    func testMinimalConfiguration() {
        let config = FloatingPlayerConfiguration.minimal
        
        XCTAssertEqual(config.defaultSize, 120)
        XCTAssertFalse(config.showControls)
        XCTAssertEqual(config.controlsTimeout, 0)
        XCTAssertEqual(config.borderWidth, 0)
        XCTAssertEqual(config.shadowRadius, 5)
        XCTAssertTrue(config.allowDragging)
    }
    
    func testFullConfiguration() {
        let config = FloatingPlayerConfiguration.full
        
        XCTAssertEqual(config.defaultSize, 180)
        XCTAssertTrue(config.showControls)
        XCTAssertEqual(config.controlsTimeout, 5.0)
        XCTAssertEqual(config.animationDuration, 0.4)
        XCTAssertEqual(config.borderWidth, 3)
        XCTAssertEqual(config.shadowRadius, 15)
        XCTAssertTrue(config.allowDragging)
        XCTAssertTrue(config.allowResizing)
    }
    
    func testCompactConfiguration() {
        let config = FloatingPlayerConfiguration.compact
        
        XCTAssertEqual(config.defaultSize, 80)
        XCTAssertEqual(config.minimumSize, 60)
        XCTAssertEqual(config.maximumSize, 120)
        XCTAssertTrue(config.showControls)
        XCTAssertEqual(config.controlsTimeout, 2.0)
        XCTAssertEqual(config.borderWidth, 1)
        XCTAssertEqual(config.shadowRadius, 5)
        XCTAssertTrue(config.allowDragging)
    }
    
    func testCustomConfiguration() {
        let customPosition = CGPoint(x: 100, y: 200)
        let customSize: CGFloat = 140
        let customConfig = FloatingPlayerConfiguration(
            defaultPosition: customPosition,
            defaultSize: customSize,
            showControls: false,
            controlsTimeout: 1.5,
            borderColor: .red,
            allowDragging: false
        )
        
        XCTAssertEqual(customConfig.defaultPosition, customPosition)
        XCTAssertEqual(customConfig.defaultSize, customSize)
        XCTAssertFalse(customConfig.showControls)
        XCTAssertEqual(customConfig.controlsTimeout, 1.5)
        XCTAssertEqual(customConfig.borderColor, .red)
        XCTAssertFalse(customConfig.allowDragging)
    }
}
