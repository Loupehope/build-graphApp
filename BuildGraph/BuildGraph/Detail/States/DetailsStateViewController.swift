//
//  DetailsStateViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 03.01.2022.
//

import AppKit

import BuildParser
import GraphParser

enum DetailsState: StateProtocol {
    case empty
    case loading
    case data(_ events: [Event], _ deps: [Dependency], _ title: String)
    case error(_ message: String, _ project: ProjectReference)
    
    static var `default`: DetailsState = .empty
}

protocol DetailsDelegate: AnyObject {
    func didLoadProject(project: ProjectReference, detailsController: DetailViewController)
    func willLoadProject(project: ProjectReference)
}

class DetailsStateViewController: StateViewController<DetailsState> {
    
    var delegate: DetailsDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            let storyboard = NSStoryboard(name: "Details", bundle: nil)
            
            switch state {
            case .empty:
                return storyboard.instantiateController(withIdentifier: "empty") as! ViewController
            case .loading:
                return storyboard.instantiateController(withIdentifier: "loading") as! ViewController
            case .data(let events, let deps, let title):
                let dataController = storyboard.instantiateController(withIdentifier: "data") as! DetailViewController
                dataController.show(events: events, deps: deps, title: title, embeddInWindow: true)
                return dataController
            case .error(let message, let project):
                // TODO: Pass message to controller
                let retryViewController = storyboard.instantiateController(withIdentifier: "retry") as! RetryViewController
                retryViewController.showNonCompilationEvents = { [unowned self] in
                    // TODO: Update settings for one project
                    self.selectProject(project: project, filter: .shared)
                }
                return retryViewController
            }
        }
    }
    
    var currentProject: ProjectReference?
    let parser = RealBuildLogParser()
    
    // TODO: compilationOnly should be customizable parameter. Best: allows to choose file types
    func selectProject(project: ProjectReference, filter: FilterSettings) {
        self.currentProject = project
        
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        
        self.state = .loading
        delegate?.willLoadProject(project: project)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            loadAndInsert(
                project: project,
                filter: filter,
                didLoad: { events, deps, title in
                    DispatchQueue.main.async {
                        self.state = .data(events, deps, title)
                        
                        derivedData?.stopAccessingSecurityScopedResource()
                        
                        delegate?.didLoadProject(project: project, detailsController: self.currentController as! DetailViewController)
                    }
                },
                didFail: { message in
                    DispatchQueue.main.async {
                        derivedData?.stopAccessingSecurityScopedResource()
                        self.state = .error(message, project)
                    }
                }
            )
        }
    }
    
    private func loadAndInsert(
        project: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ events: [Event], _ deps: [Dependency], _ title: String) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        print("will read \(project.activityLogURL), depsURL \(String(describing: project.depsURL))")
        
        do {
            let events = try parser.parse(
                logURL: project.currentActivityLog,
                filter: filter)
            
            guard events.count > 0 else {
                // TODO: depends on compilationOnly flag
                didFail(NSLocalizedString("No compilation data found", comment: ""))
                return
            }
            
            let dependencies = connectWithDependencies(events: events,
                                                       depsURL: project.depsURL)
            
            didLoad(events, dependencies, self.parser.title)
        } catch let error {
            didFail(error.localizedDescription)
        }
    }
    
    private func connectWithDependencies(events: [Event], depsURL: URL?) -> [Dependency] {
        var dependencies = [Dependency]()
        
        if let depsURL = depsURL {
            if let depsContent = try? String(contentsOf: depsURL) {
                dependencies = DependencyParser().parseFile(depsContent)
            } else {
                // TODO: Log
            }
        }
        
        events.connect(by: dependencies)
        
        return dependencies
    }
    
    // MARK: - Update filter
    func updateFilterForCurrentProject(_ filter: FilterSettings) {
        guard let project = currentProject else {
            return
        }
        
        self.state = .loading
        delegate?.willLoadProject(project: project)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            updateWithFilter(project: project, filter: filter) { events, deps, title in
                DispatchQueue.main.async {
                    guard events.count > 0 else {
                        self.state = .error("No data for current filter", project)
                        return
                    }
                    
                    self.state = .data(events, deps, title)
                    
                    delegate?.didLoadProject(
                        project: project,
                        detailsController: self.currentController as! DetailViewController)
                }
            }
        }
    }
    
    private func updateWithFilter(
        project: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ events: [Event], _ deps: [Dependency], _ title: String) -> Void
    ) {
        let events = parser.update(with: filter)
        
        let dependencies = connectWithDependencies(events: events, depsURL: project.depsURL)
        
        didLoad(events, dependencies, parser.title)
    }
}
