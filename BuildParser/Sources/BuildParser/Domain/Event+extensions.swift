//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import Foundation
import Interface

let helpersSuffix = "TestHelpers"
let testsSuffix = "TestHelpers-Unit-Tests"

extension Event {
    var type: EventType {
        if taskName.hasSuffix(helpersSuffix) {
            return .helpers
        } else if taskName.hasSuffix(testsSuffix) {
            return .tests
        } else {
            return .framework
        }
    }
    enum EventType {
        case framework
        case helpers
        case tests
    }
    
    var domain: String {
        if taskName.hasSuffix(helpersSuffix) {
            return String(taskName.dropLast(helpersSuffix.count))
        } else if taskName.hasSuffix(testsSuffix) {
            return String(taskName.dropLast(testsSuffix.count))
        } else {
            return taskName
        }
    }
    
    public var description: String {
        String(format: "\(taskName), %0.2f", duration)
    }
    
    public var dateDescription: String {
        String(format: "%0.2f, \(taskName)", duration)
    }
    
    public func output() {
        print("\n\(taskName)")
        for step in steps {
            print(step.dateDescription)
        }
    }
}

extension Array where Element == Event {
    func filter(_ suffix: String) -> [Element] {
        filter { event in
            event.taskName.hasSuffix(suffix)
        }
    }
    
    func contains(_ event: Element) -> Bool {
        self.contains { innerEvent in
            innerEvent.taskName == event.taskName
        }
    }
    
    func duration() -> TimeInterval {
        last!.endDate.timeIntervalSince(first!.startDate)
    }
    
    func start() -> Date {
        first!.startDate
    }
    
    private func date(from timeFromStart: TimeInterval) -> Date {
        Date(timeInterval: timeFromStart, since: start())
    }
    
    func concurrency(at timeFromStart: TimeInterval) -> Int {
        return concurrency(at: date(from: timeFromStart))
    }
    
    private func events(at timeFromStart: TimeInterval) -> [Event] {
        return events(at: date(from: timeFromStart))
    }
    
    func concurrency(at date: Date) -> Int {
        return events(at: date).count
    }
    
    private func events(at date: Date) -> [Event] {
        return self.filter { $0.stepsHit(time: date) }
    }
    
    func periods(concurrency: Int) -> [Date] {
        let allDates = map(\.startDate) + map(\.endDate)
        return allDates.filter { date in
            let time = date.timeIntervalSince(start()) + 0.01
            return self.concurrency(at: time) == concurrency
        }
        
        // TODO: Potential duplication with allPeriods()
    }
    
    func allPeriods() -> [Period] {
        let set: Set<Date> = map(\.dates)
            .reduce(Set()) { result, dates in
            result.union(dates)
        }
        
        guard set.count > 0 else {
            return []
        }
        
        let allDates = set.sorted()
        
        var periods = [Period]()
        for index in 0..<allDates.count - 1 {
            let start = allDates[index]
            let end = allDates[index + 1]
            let interval = end.timeIntervalSince(start)
            
            let middleTime = start.addingTimeInterval(interval / 2)
            let concurrency = concurrency(at: middleTime.timeIntervalSince(self.start()))
            let period = Period(concurrency: concurrency, start: start, end: end)
            periods.append(period)
        }
        
        return periods
    }
    
    func isBlocker(_ event: Event) -> Bool {
        let concBefore = concurrency(at: event.endDate.addingTimeInterval(-0.01))
        let concAfter  = concurrency(at: event.endDate.addingTimeInterval(0.01))
        return concAfter > concBefore
    }
}

extension Event {
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    func hit(time: Date) -> Bool {
        (startDate...endDate).contains(time)
    }
    
    func stepsHit(time: Date) -> Bool {
        steps.first { step in
            step.hit(time: time)
        } != nil
    }
    
    var dates: Set<Date> {
        Set(steps.map(\.startDate) + steps.map(\.endDate))
    }
}

struct Period {
    let concurrency: Int
    let start: Date
    let end: Date
}

func relativeStart(absoluteStart: Date, start: Date, duration: TimeInterval) -> CGFloat {
    CGFloat(start.timeIntervalSince(absoluteStart) / duration)
}

func relativeDuration(start: Date, end: Date, duration: TimeInterval) -> CGFloat {
    CGFloat(end.timeIntervalSince(start) / duration)
}
