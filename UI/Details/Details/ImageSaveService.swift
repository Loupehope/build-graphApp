//
//  ImageSaveService.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 31.10.2021.
//

import Foundation
import AppKit
import BuildParser

class FileLocationChoose {
    func requestLocation(nameFieldStringValue: String, then completion: @escaping (URL) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = nameFieldStringValue
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result == .OK {
                completion(savePanel.url!)
            }
        }
    }
}

class ImageSaveService {
    func saveImage(project: ProjectReference?, title: String?, view: NSView) {
        FileLocationChoose()
            .requestLocation(nameFieldStringValue: fileName(for: project, title: title))
        { url in
            self.setBackColorAndSave(
                url: url,
                view: view)
        }
    }
    
    private func fileName(for project: ProjectReference?, title: String?) -> String {
        guard let project = project else {
            return (title ?? Date().description)
                .appedingPngFormat
        }
        
        return ProjectDescriptionService().description(for: project)
            .appedingPngFormat
    }
    
    // TODO: Add background color
    private func setBackColorAndSave(url: URL, view: NSView) {
        let previousColor = view.layer?.backgroundColor
        defer {
            view.layer?.backgroundColor = previousColor
        }
        
        view.layer?.backgroundColor = NSColor.textBackgroundColor.effectiveCGColor
        
        writeToFile(url: url, view: view)
    }
    
    private func writeToFile(url: URL, view: NSView) {
        let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
        view.cacheDisplay(in: view.bounds, to: rep)
        
        let img = NSImage(size: view.bounds.size)
        img.addRepresentation(rep)
        
        let png = UIImagePNGRepresentation(img)
        
        do {
            try png?.write(to: url)
        } catch let error {
            print(error)
        }
    }
}

fileprivate extension String {
    var appedingPngFormat: Self {
        (self) + ".png"
    }
}

public func UIImagePNGRepresentation(_ image: NSImage) -> Data? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else { return nil }
    let imageRep = NSBitmapImageRep(cgImage: cgImage)
    imageRep.size = image.size // display size in points
    return imageRep.representation(using: .png, properties: [:])
}
