//
//  UIButton+TapClosure.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

/// The action closure for the UIButton
typealias UIButtonTargetClosure = () -> Void

/// The closure wrapper for the UIButtonTargetClosure
class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

// Extend the UIButton to be able to add a closure for the touch event
// instead of using addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents)
extension UIButton {
    // MARK: - Private properties

    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: UIButtonTargetClosure? {
        get {
            let closureWrapper = objc_getAssociatedObject(self,
                                                          &AssociatedKeys.targetClosure)
            guard let wrapper = closureWrapper as? ClosureWrapper else { return nil }

            return wrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.targetClosure,
                                     ClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Private methods

    /// Calls the target closure when button is tapped
    @objc private func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure()
    }

    // MARK: - Public methods

    /// Add target closure for touchUpInside action.
    /// Use this to replace:
    /// addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents)
    /// - Parameter closure: The closure to be called when touch happens
    @objc func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }

    /// Remove the closure
    func clearTargetClosures() {
        removeTarget(self, action: nil, for: .touchUpInside)
    }
}

