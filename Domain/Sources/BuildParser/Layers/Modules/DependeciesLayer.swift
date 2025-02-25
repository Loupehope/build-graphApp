//
//  DependeciesLayer.swift
//  
//
//  Created by Mikhail Rubanov on 24.10.2021.
//

import QuartzCore

class DependeciesLayer: ModulesLayer {
   
    var showLinks: Bool = true {
        didSet {
            criticalDependenciesLayer.isHidden = !showLinks
            regularDependenciesLayer.isHidden = !showLinks
        }
    }
    
    lazy var criticalDependenciesLayer: CAShapeLayer = {
        let bezierLayer = CAShapeLayer()
        bezierLayer.strokeColor = Colors.Dependency.critical()
        bezierLayer.fillColor = Colors.clear()
        bezierLayer.lineWidth = 1
        bezierLayer.contentsScale = contentsScale
        addSublayer(bezierLayer)
        
        return bezierLayer
    }()
    
    lazy var regularDependenciesLayer: CAShapeLayer = {
        let bezierLayer = CAShapeLayer()
        bezierLayer.strokeColor = Colors.Dependency.regular()
        bezierLayer.fillColor = Colors.clear()
        bezierLayer.lineWidth = 1
        bezierLayer.contentsScale = contentsScale
        addSublayer(bezierLayer)
        
        return bezierLayer
    }()
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        drawConnections(for: highlightedEvent)
        
        for selectedEvent in selectedEvents {
            drawConnections(for: selectedEvent)
        }
    }
    
    private func isHighlightedModule(event: Event, parent: Event) -> Bool {
        let showChild = parent.taskName == highlightedEvent?.taskName
        let showParent = event.taskName == highlightedEvent?.taskName
        let isHighlightedModule = showChild || showParent || selectedEvents.contains(event) || selectedEvents.contains(parent)
        return isHighlightedModule
    }
    
    private func drawConnectionsToParents(for event: Event, drawParents: Bool) {
        for parent in event.parents {
            let isHighlightedModule = isHighlightedModule(event: event, parent: parent)

            let isBlockerDependency = event.isBlocked(by: parent)
            
            let showBlockersOnEmptyState = event.isBlocked(by: parent)
            && highlightedEvent == nil
            && selectedEvents.isEmpty
            
            if showBlockersOnEmptyState || isHighlightedModule {
                guard let fromIndex = events.index(name: event.taskName)
                else { continue }
                
                guard let toIndex = events.index(name: parent.taskName)
                else { continue }
                
                guard fromIndex != toIndex
                else { continue }
                
                connectModules(
                    from: eventShapes[toIndex],
                    to: eventShapes[fromIndex],
                    isBlockerDependency: isBlockerDependency
                )
            }
            
            if drawParents {
                drawConnectionsToParents(for: parent, drawParents: false)
            }
        }
    }
    
    private func connectModules(
        from: CALayer,
        to: CALayer,
        isBlockerDependency: Bool)
    {
        connect(from: from.frame.rightCenter,
                to: to.frame.leftCenter,
                on: isBlockerDependency ? criticalPath : regularPath)
    }
    
    private func connect(
        from: CGPoint,
        to: CGPoint,
        on path: CGMutablePath)
    {
        let yOffset: CGFloat = (to.y - from.y) / 3 // max(10, to.x - from.x)
        let xOffset: CGFloat = (to.x - from.x)
        
        path.move(to: from)
        path.addCurve(to: to,
                      control1: from.offset(x: yOffset * 4, y: yOffset / 2),
                      control2: to.offset(x: -max(60, xOffset/2), y: 0),
                      transform: .identity)
    }
    
    func drawConnections(for event: Event?) {
        regularPath = CGMutablePath()
        criticalPath = CGMutablePath()
       
        for event in events {
            // TODO: Draw parents after some user action. Press Alt for e.g.
            let drawParents = true // event.parents.count < 20
            drawConnectionsToParents(for: event, drawParents: drawParents)
        }
        
        regularDependenciesLayer.frame = bounds
        regularDependenciesLayer.path = regularPath
        
        criticalDependenciesLayer.frame = bounds
        criticalDependenciesLayer.path = criticalPath
    }
    
    var regularPath = CGMutablePath()
    var criticalPath = CGMutablePath()
}

extension CGRect {
    
    var rightBottom: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
    
    var rightCenter: CGPoint {
        CGPoint(x: maxX, y: midY)
    }
    
    var bottomCenter: CGPoint {
        CGPoint(x: midX, y: maxY)
    }
    
    var leftCenter: CGPoint {
        CGPoint(x: minX, y: midY)
    }
}

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x,
                y: self.y + y)
    }
}

extension Array where Element == Event {
    public func index(name: String) -> Int? {
        firstIndex { event in
            event.taskName == name
        }
    }
}
