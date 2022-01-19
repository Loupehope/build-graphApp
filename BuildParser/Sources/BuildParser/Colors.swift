//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import CoreGraphics
import AppKit

struct Colors {
    static var textColor: () -> CGColor = { NSColor.labelColor.effectiveCGColor }
    static var textOverModuleColor: () -> CGColor = { NSColor.labelColor.effectiveCGColor }
    static var textInvertedColor: () -> CGColor = { NSColor.labelColor.effectiveCGColor }
    static var backColor: () -> CGColor = { NSColor.clear.effectiveCGColor }
    
    static var liftColor: () -> CGColor = { NSColor.systemGray.withAlphaComponent(0.05).effectiveCGColor }
    static var concurencyColor: () -> CGColor = { NSColor.systemRed.effectiveCGColor }
    static var timeColor: () -> CGColor = { NSColor.tertiaryLabelColor.effectiveCGColor }
    
    static var clear: () -> CGColor = { NSColor.clear.effectiveCGColor }
    
    static var dimmingAlpha: Float = 0.25
    
    struct Dependency {
        static var critical: () -> CGColor = { NSColor.systemRed.effectiveCGColor }
        static var regular: () -> CGColor = { NSColor.systemGreen.effectiveCGColor }
    }
    
    struct Events {
        static var noSubtasks: () -> CGColor = { NSColor.systemBrown.effectiveCGColor }
        static var cached: () -> CGColor = { NSColor.systemGreen.effectiveCGColor }
        static var subtask: () -> CGColor = { NSColor.systemBlue.effectiveCGColor }
        static var background: () -> CGColor = { NSColor.systemGray.effectiveCGColor }
        
        static var legendBackground: () -> CGColor = { NSColor.systemGray.effectiveCGColor }
        
        
        static var legend: [ColorDescription] {
            [
                ("Subtasks", subtask()),
                ("No subtasks", noSubtasks()),
                ("No visible subtasks", background()),
                ("Cached", cached()),
            ]
        }
    }
}

typealias ColorDescription = (desc: String, color: CGColor)

extension Event {
    var backgroundColor: CGColor {
        if parents.count == 0 {
            return Colors.Events.noSubtasks().copy(alpha: 0.25)!
        }
        
        return Colors.Events.background().copy(alpha: 0.25)!
    }
    
    var subtaskColor: CGColor {
        if fetchedFromCache {
            return Colors.Events.cached()
        }
        
        return Colors.Events.subtask ()
    }
}

func isPod(name: String) -> Bool {
    if name.hasPrefix("Firebase") {
        return true
    }
    
    if name.hasPrefix("Google") {
        return true
    }
    
    if pods.contains(name) {
        return true
    }
    
    return false
}
let pods: [String] = [
"nanopb",
"libPhoneNumber-iOS",
"SwCrypt",
"PromisesObjC",
"PinLayout",
"Nuke",
"MBProgressHUD",
"MARoundButton",
"KeychainSwift",
"KVOController",
"DeviceKit",
"CocoaAsyncSocket",
"HCaptcha-HCaptcha",
"BRYXBanner",
"Bagel"
]
