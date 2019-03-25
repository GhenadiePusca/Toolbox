//
//  UIStackView+RemoveAllSubviews.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

extension UIStackView {

    /// Removes all the subviews of the stackView
    func removeAllArrangedSubviews() {
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(arrangedSubviews.flatMap({ $0.constraints }))

        let removedSubviews = arrangedSubviews
        arrangedSubviews.forEach { self.removeArrangedSubview($0) }

        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
