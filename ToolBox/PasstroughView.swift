//
//  PasstroughView.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//  Copyright © 2019 Pusca, Ghenadie. All rights reserved.
//

import UIKit

// The passtrough view that allows passing the touch event to child views
class PassthroughView: UIView {

    // MARK: - Overriden methods
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
