import Foundation

struct Test {
    let suit: String
    let name: String
}

struct Suit {
    let name: String
    let tests: [String]
}

struct SuitDescr {
    let name: String
    let tests: String
}

func suitTests(_ suit: [String]) -> String {
    suit.map({ test in
        "❌ \(test)"
    }).joined(separator: "\n")
}


struct Report: Codable {
    let issues: Issues
    let metrics: Metrics
    let actions: Actions
    
    func failedNames() throws -> [String] {
        return issues.testFailureSummaries?._values.compactMap { value in
            return value.testCaseName._value
        } ?? []
    }
    
    func summary() -> String {
        let countOfTests = metrics.testsCount._value
        let countOfFailureTests = metrics.testsFailedCount?._value ?? "0"
        let result = "Total: \(countOfTests), Failed: \(countOfFailureTests)"
        return result
    }

    func total() -> String {
         metrics.testsCount._value
    }

    func failed() -> String {
        metrics.testsFailedCount?._value ?? "0"
    }

    func skipped() -> String {
        metrics.testsSkippedCount?._value ?? "0"
    }
    
    func testsRefId() -> String? {
        actions._values.first?.actionResult.testsRef?.id._value
    }
}

extension Report: CustomDebugStringConvertible {
    var debugDescription: String {
        var descr = "\n- - - - - - - - - - - - - -\n\n"
        
        descr.append("Total Tests: \t\t \(metrics.testsCount.intValue) \n")
        
        if let warningsCount = metrics.warningCount?.intValue {
            descr.append("Warnings: \t\t\t \(warningsCount) \n")
        }
        
        descr.append("\n- - - - - - - - - - - - - -\n")
        return descr
    }
}

struct Issues: Codable {
    let testFailureSummaries: TestFailureSummaries?
}

struct TestFailureSummaries: Codable {
    let _values: [FailureValue]
}

struct FailureValue: Codable {
    let testCaseName: Value
}

// metrics for func summary
struct Metrics: Codable {
    let testsCount: IntValue
    let testsFailedCount: IntValue?
    let testsSkippedCount: IntValue?
    let warningCount: IntValue?
}

class Value: Codable {
    internal let _value: String
}

class IntValue: Value {
    var intValue: Int {
        Int(_value) ?? 0
    }
}

// MARK:- TestsRef models
struct Actions: Codable {
    let _values: [ActionRecord]
}

struct ActionRecord: Codable {
    let actionResult: ActionResult
}

struct ActionResult: Codable {
    let testsRef: Ref?
}

struct Ref: Codable {
    let id: Value
}
