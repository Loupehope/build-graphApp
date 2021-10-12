//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import QuartzCore

extension CALayer {
    public func updateWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        block()
        CATransaction.commit()
    }
}

public class Graph: CALayer {
    let events: [Event]
    public var highlightedEvent: Event? = nil {
        didSet {
            updateWithoutAnimation {
                setNeedsLayout()
                layoutIfNeeded()
            }
            
            higlightedLift.opacity = (highlightedEvent != nil) ? 1: 0
        }
    }
    
    private(set) var shapes: [CALayer]
    private let higlightedLift: CALayer
    private(set) var texts: [CATextLayer]
    private let rects: [EventRelativeRect]
    
    private let concurrencyLine: CALayer
    private let concurrencyTitle: CATextLayer
    
    private let periods: [Period]
    private var periodsShapes: [CALayer]
    
    public init(events: [Event], scale: CGFloat) {
        self.events = events
        
        self.rects = events.map { event in
            EventRelativeRect(event: event,
                              absoluteStart: events.start(),
                              totalDuration: events.duration())
        }
        self.shapes = .init()
        self.higlightedLift = .init()
        self.texts = .init()
        
        self.concurrencyLine = CALayer()
        self.concurrencyTitle = CATextLayer()
        
        self.periods = events.allPeriods()
        self.periodsShapes = .init()
        
        super.init()
        
        setup(scale: scale)
    }
    public override init(layer: Any) {
        let layer = layer as! Graph
        
        self.events = layer.events
        self.shapes = layer.shapes
        self.texts = layer.texts
        self.higlightedLift = layer.higlightedLift
        self.rects = layer.rects
        
        self.concurrencyLine = layer.concurrencyLine
        self.concurrencyTitle = layer.concurrencyTitle
        self.coordinate = layer.coordinate
        
        self.periods = layer.periods
        self.periodsShapes = layer.periodsShapes
        super.init(layer: layer)
    }
   
    // MARK: - Event
    public func highlightEvent(at coordinate: CGPoint) {
        let event = event(at: coordinate)
        highlightedEvent = event
    }
    
    public var coordinate: CGPoint? = .zero {
        didSet {
            updateWithoutAnimation {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    public func drawConcurrency(at coordinate: CGPoint) {
        self.coordinate = coordinate
        
        let relativeX = coordinate.x / frame.width
        let time = events.duration() * relativeX
        let concurency = events.concurrency(at: time)
        concurrencyTitle.string = "\(concurency)"
        print(concurency)
    }
    
    private func event(at coorditate: CGPoint) -> Event? {
        for (i, shape) in shapes.enumerated() {
            if shape
                .frame.insetBy(dx: 0, dy: -space/2)
                .inLine(
                    coorditate
                ) {
                return events[i]
            }
        }
        return nil
    }
    
    // MARK: - Drawing
    private func setup(scale: CGFloat) {
        
        for period in periods {
            let periodLayer = CALayer()
            let alpha: CGFloat = 1 / CGFloat(period.concurrency)
            periodLayer.backgroundColor = .init(red: 1,
                                                green: 0, blue: 0, alpha: alpha / 4)
            periodsShapes.append(periodLayer)
            addSublayer(periodLayer)
        }
        
        higlightedLift.backgroundColor = Colors.liftColor
        self.higlightedLift.frame = .zero
        addSublayer(higlightedLift)
        
        concurrencyLine.backgroundColor = Colors.concurencyColor
        addSublayer(concurrencyLine)
        
        concurrencyTitle.contentsScale = scale
        concurrencyTitle.foregroundColor = Colors.concurencyColor
        concurrencyTitle.fontSize = 20
        addSublayer(concurrencyTitle)
        
        for _ in rects {
            let layer = CALayer()
            layer.contentsScale = scale
            shapes.append(layer)
            addSublayer(layer)
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = scale
            texts.append(textLayer)
            self.addSublayer(textLayer)
        }
        
        backgroundColor = Colors.backColor
    }
    
    private func alpha(for rect: EventRelativeRect) -> CGFloat {
        if let highlightedEvent = highlightedEvent {
            if rect.event.domain == highlightedEvent.domain {
                return 1
            } else {
                return Colors.dimmingAlpha
            }
        } else {
            return 1
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var concurrencyHidden: Bool = false {
        didSet {
            let opacity: Float = concurrencyHidden ? 0: 1
            concurrencyLine.opacity = opacity
            concurrencyTitle.opacity = opacity
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        let duration = events.duration()
        for (i, period) in periods.enumerated() {
            let layer = periodsShapes[i]
            
            let relativeStart = relativeStart(absoluteStart: events.start(),
                                              start: period.start,
                                              duration: duration)
            let relativeDuration = relativeDuration(start: period.start,
                                                    end: period.end,
                                                    duration: duration)
            layer.frame = CGRect(x: relativeStart * self.frame.width,
                                 y: 0,
                                 width: relativeDuration * self.frame.width,
                                 height: self.frame.height)
        }
        
        if let coordinate = coordinate {
            concurrencyHidden = false
            concurrencyLine.frame = CGRect(x: coordinate.x,
                                           y: 0,
                                           width: 1,
                                           height: frame.height)
            let titleHeight: CGFloat = 20
            concurrencyTitle.frame = CGRect(x: coordinate.x + 10,
                                            y: coordinate.y - titleHeight - 10,
                                            width: 100,
                                            height: titleHeight)
        } else {
            concurrencyHidden = true
        }
        
        for (i, shape) in shapes.enumerated() {
            let rect = rects[i]
            let frame = frame(for: i, rect: rect)
            shape.frame = frame
            shape.backgroundColor = rect.backgroundColor.copy(alpha: alpha(for: rect))
            
            drawText(rect: rect, i: i, frame: frame)
            
            if rect.event.taskName == highlightedEvent?.taskName {
                higlightedLift.frame = CGRect(x: frame.minX,
                                              y: 0, width: frame.width,
                                              height: self.frame.height)
            }
        }
    }
    
    private func frame(for i: Int, rect: EventRelativeRect) -> CGRect {
        let width = self.frame.width
        
        return CGRect(x: width * rect.start,
                      y: CGFloat(i) * (self.height + space),
                      width: width * rect.duration,
                      height: self.height)
    }
    
    private func drawText(rect: EventRelativeRect, i: Int, frame: CGRect) {
        let text = texts[i]
        text.string = rect.text
        text.frame = CGRect(x: frame.maxX + 2,
                            y: frame.minY + 1,
                            width: 150, // TODO: calculate on fly
                            height: height)
        text.foregroundColor = Colors.textColor
        text.fontSize = fontSize
    }
    
    let height: CGFloat = 8
    let space: CGFloat = 1
    let fontSize: CGFloat = 5

    public var intrinsicContentSize: CGSize {
        return CGSize(width: 2400,
                      height: CGFloat(rects.count) * (height + space))
    }
}
extension CGRect {
    func inLine(_ coordinate: CGPoint) -> Bool {
        (minY...maxY).contains(coordinate.y)
    }
}
