//
//  UIView+TouchAreaInsets.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

extension UIView {
    struct AssociatedKeys {
        static var edgeInsetsKey = "edgeInset"
    }

    /// The inset to enlarge the UIVIew touch inset
    var touchEdgeInsets: UIEdgeInsets {
        get {
            if let edgeInset = objc_getAssociatedObject(self, &AssociatedKeys.edgeInsetsKey) as? UIEdgeInsets {
                return edgeInset
            }

            let initValue = UIEdgeInsets()
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.edgeInsetsKey,
                                     initValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return initValue
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.edgeInsetsKey,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Will swizzle the touch area to allow specifying the touchAreaInsets
    class func swizzleTouchArea() {
        guard let swizzledMethod = class_getInstanceMethod(self, #selector(point(inside:with:))),
            let replacementMethod = class_getInstanceMethod(self, #selector(touchAreaPoint(inside:with:)))
            else {
                return
        }

        method_exchangeImplementations(swizzledMethod, replacementMethod)
    }

    /// Adjusts the touch area with provided touchEdgeInsets
    @objc func touchAreaPoint(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let touchBounds = CGRect(x: bounds.origin.x - touchEdgeInsets.left,
                                 y: bounds.origin.y - touchEdgeInsets.top,
                                 width: bounds.size.width + touchEdgeInsets.left + touchEdgeInsets.right,
                                 height: bounds.size.height + touchEdgeInsets.top + touchEdgeInsets.bottom)
        return touchBounds.contains(point)
    }
}
