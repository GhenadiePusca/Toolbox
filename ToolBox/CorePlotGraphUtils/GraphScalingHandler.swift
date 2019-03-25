//
//  GraphScalingHandler.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import CorePlot

@objc protocol GraphScalingHandlerDelegate: class {
    // Called when scaling gesture starts
    func willStartScaling(_ scalingHandler: GraphScalingHandler)
    // Called when the scaling animation ends
    func didEndScaling(_ toRange: CPTPlotRange?, isInitialRange: Bool, scalingHandler: GraphScalingHandler)
}

class GraphScalingHandler: NSObject, CPTPlotSpaceDelegate, CPTAnimationDelegate {

    private var isScaling = false
    private var scalingDoneTimer: Timer?
    private var graph: CPTXYGraph?
    private var shouldScaleToInitialRange = false
    private var isDoubleTapScalingEnabled = true
    private var isPinchScalingEnabled = true {
        didSet {
            self.graph?.defaultPlotSpace?.allowsUserInteraction = self.isPinchScalingEnabled
        }
    }
    private var isDraggingEnabled = false
    private var initialRange: CPTPlotRange?

    // It's not mandatory to set the initialXRange, when attached to the graph, the handler will
    // get the graph X range at the moment when it's attached, but this do not assure the initial X Range will be correct.
    @objc var initialXRange: CPTPlotRange? = nil {
        didSet {
            self.initialRange = initialXRange
        }
    }

    @objc weak var delegate: GraphScalingHandlerDelegate?

    // Scaling gestures
    var xAxisDoubleTapScalingEnable = true { // 2x scale
        didSet {
            self.isDoubleTapScalingEnabled = self.enabled && self.xAxisDoubleTapScalingEnable
        }
    }
    var xAxisPinchScalingEnable = true {
        didSet {
            self.isPinchScalingEnabled = self.enabled && self.xAxisPinchScalingEnable
        }
    }
    var xAxisDraggingEnable = true {
        didSet {
            self.isDraggingEnabled = self.enabled && self.xAxisDraggingEnable
        }
    }

    // Will enable/disable the graph scaling.
    // It will be better to enable the handler after the graph is fully drawn.
    @objc var enabled: Bool = false {
        didSet {
            self.graph?.defaultPlotSpace?.delegate = self.enabled ? self : nil
            self.isDoubleTapScalingEnabled = self.enabled && self.xAxisDoubleTapScalingEnable
            self.isPinchScalingEnabled = self.enabled && self.xAxisPinchScalingEnable
            self.isDraggingEnabled = self.enabled && self.xAxisDraggingEnable
        }
    }

    var scalingFactor: Double = 3

    @objc func attachToGraph(graph: CPTXYGraph) {
        self.graph = graph
        self.initialRange = (graph.defaultPlotSpace as? CPTXYPlotSpace)?.xRange
    }

    func scaleToInitialRange() {
        if(!self.enabled) {
            return
        }
        guard let initXRange = self.initialXRange,
            let plotSpace = self.graph?.defaultPlotSpace as? CPTXYPlotSpace else{
                return
        }

        self.shouldScaleToInitialRange = true
        CPTAnimation.animate(plotSpace, property: "xRange",
                             from: plotSpace.xRange,
                             to: initXRange, duration: 0.2, animationCurve: .cubicInOut, delegate: self)
    }

    // MARK: PlotSpace delegate
    internal func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event: UIEvent, at point: CGPoint) -> Bool {

        if !self.enabled {
            return false
        }

        guard let aGraph = self.graph, let plotArea = aGraph.plotAreaFrame?.plotArea, let initXRange = self.initialRange,
            let plotSpace = aGraph.defaultPlotSpace as? CPTXYPlotSpace else{
                return false
        }

        guard let nrOfTouches = event.allTouches?.first?.tapCount else {
            return false
        }

        if nrOfTouches == 2 {
            if !self.isDoubleTapScalingEnabled {
                return false
            }

            guard let newPlotRange = initXRange.mutableCopy() as? CPTMutablePlotRange else {
                return false
            }

            if initXRange.lengthDouble == plotSpace.xRange.lengthDouble {
                // Scale in
                let scaleAmount: Double = plotSpace.xRange.lengthDouble / 2
                let plotPoints: UnsafeMutablePointer<Decimal> = UnsafeMutablePointer<Decimal>.allocate(capacity: 2)
                let plotAreaPoint = aGraph.convert(point, to: plotArea)
                plotSpace.plotPoint(plotPoints, numberOfCoordinates: 2, forPlotAreaViewPoint: plotAreaPoint)
                let xCoordintate = NSDecimalNumber(decimal: plotPoints[0]).doubleValue

                newPlotRange.location = NSNumber(value: xCoordintate - scaleAmount/2)
                newPlotRange.length = NSNumber(value: scaleAmount)

                plotPoints.deinitialize()
                plotPoints.deallocate(capacity: 2)
            }

            CPTAnimation.animate(plotSpace, property: "xRange", from: plotSpace.xRange, to: newPlotRange, duration: 0.2, animationCurve: .cubicInOut, delegate: nil)
        }
        return true
    }

    internal func plotSpace(_ space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, for coordinate: CPTCoordinate) -> CPTPlotRange? {
        if coordinate == .Y {
            return (space as? CPTXYPlotSpace)?.yRange
        }

        if(!self.isScaling) {
            self.delegate?.willStartScaling(self)
            self.resetScalingDoneTimer()
        }

        self.isScaling = true

        if self.shouldScaleToInitialRange {
            return self.initialRange
        }

        if !self.enabled {
            return (space as? CPTXYPlotSpace)?.xRange
        }

        guard let mutableRange = newRange.mutableCopy() as? CPTMutablePlotRange else {
            return self.initialRange
        }

        guard let initXRange = self.initialRange else {
            return (space as? CPTXYPlotSpace)?.xRange
        }

        if mutableRange.lengthDouble > initXRange.lengthDouble {
            return initXRange
        }

        if mutableRange.locationDouble < initXRange.locationDouble {
            mutableRange.locationDouble = initXRange.locationDouble
        }

        if self.isPinchScalingEnabled {
            let minimalXRange = (initXRange.lengthDouble / self.scalingFactor)
            if mutableRange.lengthDouble < minimalXRange {
                mutableRange.lengthDouble = minimalXRange
            }
        }

        if (mutableRange.locationDouble + mutableRange.lengthDouble) > (initXRange.locationDouble + initXRange.lengthDouble) {
            mutableRange.locationDouble = initXRange.locationDouble + initXRange.lengthDouble - mutableRange.lengthDouble;
        }

        return mutableRange;
    }

    internal func plotSpace(_ space: CPTPlotSpace, didChangePlotRangeFor coordinate: CPTCoordinate) {
        self.resetScalingDoneTimer()
    }

    internal func resetScalingDoneTimer() {
        self.scalingDoneTimer?.invalidate()
        self.scalingDoneTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self,
                                                     selector: #selector(scalingDone), userInfo: nil,
                                                     repeats: false)
    }

    internal func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceDraggedEvent event: UIEvent, at point: CGPoint) -> Bool {
        return self.isDraggingEnabled
    }

    internal func animationDidFinish(_ operation: CPTAnimationOperation) {
        self.shouldScaleToInitialRange = false
        self.scalingDone()
    }

    @objc internal func scalingDone() {
        self.isScaling = false
        let newRange = (self.graph?.defaultPlotSpace as? CPTXYPlotSpace)?.xRange
        let isInitialRange = newRange?.lengthDouble == self.initialRange?.lengthDouble

        self.delegate?.didEndScaling(newRange, isInitialRange: isInitialRange, scalingHandler: self)
    }
}
