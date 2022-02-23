//
//  WindowController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 04.01.2022.
//

import AppKit
import BuildParser

class WindowController: NSWindowController {
    
    func window() -> MainWindow {
        window as! MainWindow
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window!.toolbar!.delegate = self
        window().setupToolbar(window!.toolbar!)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let filterSettingsController = segue.destinationController as? SettingsPopoverViewController {
            filterSettingsController.counter = splitViewController().detail.presenter.parser.makeCounter()
            filterSettingsController.delegate = splitViewController()
            filterSettingsController.settings = splitViewController().filter
        }
    }
    
    @IBAction func makeScreenshotOfGraph(_ sender: Any) {
        guard let detailController = splitViewController().detail.currentController as? DetailViewController else {
            return
        }
        
        detailController.shareImage()
    }
    
    @IBAction func searchDidChange(_ sender: NSSearchField) {
        let text = sender.stringValue
     
        guard let detailController = splitViewController().detail.currentController as? DetailViewController else { return }
        
        detailController.search(text: text)
    }
    
    @IBAction func previousProjectDidPress(_ sender: Any) {
        projectsController?.selectNextFile()
    }
    
    @IBAction func nextProjectDidPress(_ sender: Any) {
        projectsController?.selectPreviousFile()
    }
    
    private var projectsController: ProjectsOutlineViewController? {
        // TODO: Rework
        splitViewController().projects.currentController as? ProjectsOutlineViewController
    }
    
    func splitViewController() -> SplitController {
        return self.contentViewController as! SplitController
    }
}

extension WindowController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .refresh:
            let refresh = NSToolbarItem(itemIdentifier: itemIdentifier)
            refresh.image = NSImage(systemSymbolName: "arrow.clockwise",
                                    accessibilityDescription: NSLocalizedString("Refresh projects", comment: "Toolbar button"))
            refresh.label = NSLocalizedString("Refresh", comment: "Toolbar button")
            refresh.target = self
            refresh.action = #selector(self.refresh)
            refresh.isEnabled = true
            return refresh
        default:
            fatalError()
        }
    }
    
    @objc func refresh() {
        splitViewController().projectsPresenter.reloadProjetcs()
    }
}

extension NSToolbarItem.Identifier {
    static let refresh = Self(rawValue: "Refresh")
}
