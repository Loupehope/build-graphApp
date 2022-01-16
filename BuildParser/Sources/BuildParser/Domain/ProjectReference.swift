//
//  ProjectReference.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import Foundation

public class ProjectReference: Equatable {
    public static func == (lhs: ProjectReference, rhs: ProjectReference) -> Bool {
        lhs.name == rhs.name
        && lhs.activityLogURL == rhs.activityLogURL
        && lhs.depsURL == rhs.depsURL
    }
    
    public init(
        name: String,
        activityLogURL: [URL],
        depsURL: URL?
    ) {
        precondition(activityLogURL.count > 0)
        
        self.currentActivityLogIndex = 0
        self.name = name
        self.activityLogURL = activityLogURL
        self.depsURL = depsURL
    }
    
    public let name: String
    public let activityLogURL: [URL]
    
    // MARK:  - Current File
    public var currentActivityLogIndex: Int
    public var currentActivityLog: URL {
        activityLogURL[currentActivityLogIndex]
    }
    
    public var indexDescription: String {
        "\(currentActivityLogIndex + 1) of \(activityLogURL.count)"
    }
    
    // MARK: Previous file
    public func canDecreaseFile() -> Bool {
        currentActivityLogIndex > 0
    }
    
    public func selectPreviousFile() {
        precondition(canDecreaseFile())
        
        self.currentActivityLogIndex -= 1
    }
    
    // MARK: Next file
    public func canIncreaseFile() -> Bool {
        currentActivityLogIndex < activityLogURL.count - 1
    }
    
    public func selectNextFile() {
        precondition(canIncreaseFile())
        
        self.currentActivityLogIndex += 1
    }
    
    public let depsURL: URL?
    
    static func shortName(from fileName: String) -> String {
        fileName.components(separatedBy: "-").dropLast().joined(separator: "-")
    }
}
