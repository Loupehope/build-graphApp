//
//  DetailView.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 02.01.2022.
//

import Cocoa
import BuildParser
import GraphParser
import Interface
import XCLogParser

class DetailView: NSView {
    var modulesLayer: AppLayer?
    var hudLayer: HUDLayer?
    
    @IBOutlet weak var scrollView: NSScrollView!
    let contentView = FlippedView()
    
    func showEvents(events: [Event]) {
        let scale = NSScreen.main!.backingScaleFactor
        
        modulesLayer = AppLayer(
            events: events,
            scale: scale)
        
        hudLayer = HUDLayer(events: events, scale: scale)
        needsLayout = true
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(modulesLayer!)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        scrollView.layer?.addSublayer(hudLayer!)
        scrollView.automaticallyAdjustsContentInsets = false
    }
    
    override func layout() {
        super.layout()
        
        hudLayer?.frame = bounds
    }
    
    override func updateLayer() {
        super.updateLayer()
        
        modulesLayer?.setNeedsLayout()
        hudLayer?.setNeedsLayout()
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        
        guard let events = modulesLayer?.events else {
            return
        }
        
        removeLayer()
        showEvents(events: events)
        updateSettings()
    }
    
    func removeLayer() {
        for layer in (contentView.layer?.sublayers ?? []) {
            layer.removeFromSuperlayer()
        }
        
        modulesLayer = nil
    }
    
    // TODO: Move setting to layer initialization
    let uiSettings = UISettings()
    private func updateSettings() {
        modulesLayer?.showPerformance = uiSettings.showPerformance
        modulesLayer?.showLinks = uiSettings.showLinks
        modulesLayer?.showSubtask = uiSettings.showSubtask
    }
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}
