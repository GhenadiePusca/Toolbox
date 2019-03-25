//
//  UIView+TapClosure.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

/// The tap closure for the view
typealias TapClosure = () -> Void

/// The closure wrapper for the TapClosure
fileprivate class TapClosureWrapper: NSObject {
    let closure: TapClosure
    init(_ closure: @escaping TapClosure) {
        self.closure = closure
    }
}

/// This extension provides the ability to add tap gesture to the view
extension UIView {

    // MARK: - Private properties

    private struct AssociatedKey {
        static var tapClosure = "tapClosure"
    }

    private var tapClosure: TapClosure? {
        get {
            let closureWrapper = objc_getAssociatedObject(self,
                                                          &AssociatedKey.tapClosure)
            guard let wrapper = closureWrapper as? TapClosureWrapper else { return nil }

            return wrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self,
                                     &AssociatedKey.tapClosure,
                                     TapClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Adds the tap gesture recognizer to the view.
    /// Enables the user interaction on the view.
    ///
    /// - Parameter closure: The closure to be executed when user taps on the view
    func addTapGesture(_ closure: @escaping TapClosure) {
        tapClosure = closure
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIView.tapClosureAction))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    /// Calls the target closure when view is tapped
    @objc private func tapClosureAction() {
        tapClosure?()
    }
}
