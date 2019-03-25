//
//  UITableView+HeaderFooterLayout.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

/// It is needed to correctly calculate the height of the UITableView Header and Footer,
/// as those do not participate in Auto Layout
extension UITableView {

    /// Size the header to fit its content
    func sizeHeaderToFit() {
        guard let headerView = tableHeaderView else {
            return
        }

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame

        tableHeaderView = headerView
    }

    /// Size the footer to fit its content
    func sizeFooterToFit() {
        guard let footerView = tableFooterView else {
            return
        }

        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()

        let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = footerView.frame
        frame.size.height = height
        footerView.frame = frame

        tableFooterView = footerView
    }
}

