//
//  ViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}

class ViewController: NSViewController {

    var layer: Graph!
    @IBOutlet weak var scrollView: NSScrollView!
    let contentView = FlippedView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "AppEventsMoveDataPerstance", withExtension: "json")!
        let events = try! BuildLogParser().parse(path: url)
        layer = Graph(
            events: events,
            scale: NSScreen.main!.backingScaleFactor)
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(layer)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        addMouseTracking()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        layer.updateWithoutAnimation {
            layer.frame = CGRect(x: 0, y: 0,
                                 width: view.frame.width,
                                 height: layer.intrinsicContentSize.height)
            layer.layoutIfNeeded()
        }
        contentView.frame = layer.frame
        contentView.bounds = layer.frame
        
//        self.view.window?.minSize = NSSize(width: 500, height: min(400, layer.frame.height)) // Don't work
    }
    
    var trackingArea: NSTrackingArea!
    func addMouseTracking() {
        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways,
                      .mouseMoved,
                      .mouseEnteredAndExited,
                      .inVisibleRect],
            owner: self,
            userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = true
        view.window?.makeFirstResponder(self)
    }
    
    override func mouseMoved(with event: NSEvent) {
        let coordinate = contentView.convert(
            event.locationInWindow,
            from: nil)
        
        layer.highlightEvent(at: coordinate)
        layer.drawConcurrency(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        layer.highlightedEvent = nil
        layer.coordinate = nil
    }
}
