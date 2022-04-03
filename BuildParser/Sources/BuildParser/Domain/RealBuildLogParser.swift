//
//  RealBuildLogParser.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import XCLogParser
import Foundation
import os

public class FilterSettings {
    public static var shared = FilterSettings()
    
    public init() {}
    
    public var showCached: Bool = true
    
    public var allowedTypes: [DetailStepType] = DetailStepType.compilationSteps
    
    public func add(stepType: DetailStepType) {
        allowedTypes.append(stepType)
    }
    
    public func remove(stepType: DetailStepType) {
        guard let indexToRemove = allowedTypes.firstIndex(of: stepType) else {
            return
        }
        allowedTypes.remove(at: indexToRemove)
    }
    
    public func enableAll() {
        allowedTypes = DetailStepType.allCases
    }
}

extension DetailStepType {
    static var compilationSteps: [Self] {
        Self.allCases
            .filter { $0.isCompilationStep() }
    }
}

public class RealBuildLogParser {
   
    public init() {}
    
    let activityLogParser = ActivityParser()
    let buildParser = ParserBuildSteps(
        machineName: nil,
        omitWarningsDetails: true,
        omitNotesDetails: true)
    
    var buildStep: BuildStep!
    public func makeCounter() -> BuildStepCounter {
        BuildStepCounter(buildStep: buildStep)
    }
    
    public var title: String {
        buildStep.title
    }
    
    var progress = Progress(totalUnitCount: 3)
    
    public func parse(logURL: URL, filter: FilterSettings) throws -> [Event] {
        progress = Progress(totalUnitCount: 3)
        os_log("start parsing")
        var date = Date()
        
        let activityLog = try activityLogParser.parseActivityLogInURL(logURL)
        
        var diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("read activity log, \(diff)")
        }
        date = Date()
        
        progress.completedUnitCount = 1
        
        buildStep = try buildParser.parse(activityLog: activityLog)
        progress.completedUnitCount = 2
        diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("parse logs, \(diff)")
        }
        date = Date()
        
        let events = convertToEvents(buildStep: buildStep, filter: filter)
        progress.completedUnitCount = 3
        diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("convert events, \(diff)")
        }
        
        return events
    }
    
    public func update(with filter: FilterSettings) -> [Event] {
        convertToEvents(buildStep: buildStep, filter: filter)
    }
    
    public func step(for event: Event) -> BuildStep? {
        let step = buildStep.subSteps.first { step in
            step.title.hasSuffix(event.taskName)
        }
        
        return step
    }
    
    let dateFormatter = DateFormatter.iso8601Full_Z
    
    func convertToEvents(
        buildStep: BuildStep,
        filter: FilterSettings
    ) -> [Event] {
        
        let events: [Event] = buildStep.subSteps
            .parallelCompactMap { step -> Event? in
                var substeps = step.subSteps
                
                // TODO: Speedup if all or none settings are enabled
                substeps = substeps.filter { substep in
                    filter.allowedTypes.contains(substep.detailStepType)
                    && substep.startDate > buildStep.startDate // TODO: Investigate non cached old tasks
                }
                
                if !filter.showCached && step.fetchedFromCache {
                    return nil
                }
                
                guard
                    let startDate = substeps.first?.startDate,
                    let endDate = substeps.last?.endDate
                else {
                    return nil // Empty array
                }
                
                return self.event(from: step,
                                  startDate: startDate,
                                  duration: endDate.timeIntervalSince(startDate),
                                  substeps: substeps)
            }
            .sorted { lhsEvent, rhsEvent in
                if lhsEvent.startDate == rhsEvent.startDate {
                    return lhsEvent.taskName < rhsEvent.taskName
                } else {
                    return lhsEvent.startDate < rhsEvent.startDate
                }
            }
        
        return events
    }
    
    public func convertToEvents(
        subSteps: [BuildStep]
    ) -> [Event] {
        let events = subSteps
            .map { step in
                event(from:step, startDate: step.startDate, duration: step.duration, substeps: step.subSteps)
            }
            .sorted { lhsEvent, rhsEvent in
                if lhsEvent.startDate == rhsEvent.startDate {
                    return lhsEvent.taskName < rhsEvent.taskName
                } else {
                    return lhsEvent.startDate < rhsEvent.startDate
                }
            }
        return events
    }
    
    private func event(from step: BuildStep,
                       startDate: Date,
                       duration: TimeInterval,
                       substeps: [BuildStep]) -> Event {
        Event(
            taskName: step.title.without_Build_target,
            startDate: startDate,
            duration: duration,
            fetchedFromCache: step.fetchedFromCache,
            steps: self.convertToEvents(subSteps: substeps)
        )
    }
}

extension DateFormatter {
    public static let iso8601Full_Z: DateFormatter = {
        dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
    }()
    
    static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

extension Collection {
    // Atother implementation https://talk.objc.io/episodes/S01E90-concurrent-map
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)
        
        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }
        
        return res.map({ $0! })
    }
    
    func parallelCompactMap<R>(_ transform: @escaping (Element) -> R?) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)
        
        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            if let result = transform(self[index(startIndex, offsetBy: i)]) {
                lock.lock()
                res[i] = result
                lock.unlock()
            }
        }
            
        return res.compactMap { $0 }
    }
}

extension String {
    // TODO: Add tests
    // 1. "Build target Crypto"
    // 2. "Crypto"
    var without_Build_target: String {
        let prefix = "Build target "
        if self.hasPrefix(prefix) {
            return String(self.suffix(count - prefix.count))
        } else {
            return self
        }
    }
}

extension BuildStep {
    func description(prefixString: String = "") -> String {
        var description = String(format: "%0.2f \(title)\n", duration)
        
        for substep in subSteps {
            if substep.subSteps.count > 0 {
                description.append(substep.description(prefixString: prefixString + "\t"))
            } else {
                description.append(String(format: "\(prefixString)%0.2f\t\(substep.title)\n", substep.duration))
            }
        }
        
        return description
    }
    
    func output() {
        print(description)
    }
}
