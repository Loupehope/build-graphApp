//
//  DetailView.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 02.01.2022.
//

import Cocoa
import BuildParser
import GraphParser
import XCLogParser

class DetailView: NSView {
    var modulesLayer: AppLayer?
    
    @IBOutlet weak var hudView: HUDView!
    @IBOutlet weak var scrollView: HUDScrollView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var zoomInButton: NSButton!
    @IBOutlet weak var zoomOutButton: NSButton!
    
    var contentView = FlippedView()
    
    var project: Project?
    func show(project: Project) {
        self.project = project
        let scale = NSScreen.main!.backingScaleFactor
        
        modulesLayer = AppLayer(
            events: project.events,
            relativeBuildStart: project.relativeBuildStart,
            fontSize: CGFloat(UISettings().textSize), // TODO: Move to parameters?
            scale: scale)
        
        needsLayout = true
        
        contentView = FlippedView()
        contentView.wantsLayer = true
        contentView.layer?.masksToBounds = false
        contentView.layer?.addSublayer(modulesLayer!)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = .zero
        
        hudView.setup(duration: project.events.duration(),
                      legendIsHidden: !UISettings().showLegend, // TODO: Move to parameters?
                      scale: scale)
        scrollView.hudLayer = hudView.hudLayer
//        modulesLayer?.addSublayer(hudLayer!)
        
        layoutModules() // calc intrinsic content size
        layoutSubtreeIfNeeded()
    }
    
    override func updateLayer() {
        super.updateLayer()
        
        modulesLayer?.setNeedsLayout()
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        
        recreateHierarchy()
    }
    
    func recreateHierarchy() {
        guard let project = project else {
            return
        }
        
        removeLayer()
        show(project: project)
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
    
    private func contentSize(appLayer: AppLayer) -> CGSize {
        let contentHeight = appLayer.intrinsicContentSize.height
        
        let offset: CGFloat = 10
        
        return CGSize(width: max(500, frame.width - offset),
                      height: max(500, contentHeight)) // TODO: Define max as height of projects view
    }
    
    private func layoutModules() {
        let contentSize = contentSize(appLayer: modulesLayer!)
        
        setModules(size: contentSize)
    }
    
    func resizeOnWindowChange() {
        setModules(
            size: CGSize(
                width: bounds.width,
                height: max(
                    bounds.size.height,
                    contentSize(appLayer: modulesLayer!).height
                )
            )
        )
    }
    
    private func setModules(size: CGSize) {
        modulesLayer!.updateWithoutAnimation {
            modulesLayer!.frame = CGRect(
                x: 0, y: 0,
                width: size.width,
                height: size.height)
            modulesLayer!.layoutIfNeeded()
        }
        
        contentView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: size.width,
                                   height: size.height - 52)
    }
    
    func resizeWindowHeightIfPossible() {
        let isFullscreen = NSApplication.shared.presentationOptions.contains(.fullScreen)
        guard !isFullscreen else { return }
        guard let window = window as? MainWindow else { return }
        
        let contentSize = contentSize(appLayer: modulesLayer!)
        let newHeight = contentSize.height + safeAreaInsets.top
        
        window.resizeWindowHeight(to: newHeight)
    }
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}
