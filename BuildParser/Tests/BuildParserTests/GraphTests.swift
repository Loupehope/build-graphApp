//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 12.10.2021.
//

import XCTest
@testable import BuildParser

import SnapshotTesting

final class GraphTests: XCTestCase {
    
    let record = false
    
    let parser = BuildLogParser()
    
    func test_drawingAppEvents() throws {
        let events = try parser.parse(path: appEventsPath)
        let view = Graph(events: events, scale: 3)
        
        view.frame = .init(x: 0,
                           y: 0,
                           width: view.intrinsicContentSize.width,
                           height: view.intrinsicContentSize.height)
        let layer: CALayer = view
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
    
    func test_drawingTestEvents() throws {
        let events = try parser.parse(path: testEventsPath)
        let view = Graph(events: events, scale: 3)
        view.highlightedEvent = events[100]
        
        view.frame = .init(x: 0,
                           y: 0,
                           width: view.intrinsicContentSize.width,
                           height: view.intrinsicContentSize.height)
        let layer: CALayer = view
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
}
