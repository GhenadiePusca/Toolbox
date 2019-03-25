//
//  ConfigurableProtocols.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

/// The protocol for the entity that can be registerd in table view, collectionView
protocol Registrable {
    /// The reuse identifier for the registered class
    var reuseIdentifier: String { get }

    /// The register class
    var registerClass: AnyClass { get }

    /// The register nib if exists. The nib will be used for register if it does exists.
    /// Otherwise registerClass will be used
    var registerNib: UINib? { get }
}

/// The protocol for the entity that can be updated with an view model
protocol ViewModelUpdatable {
    associatedtype ViewModel

    /// Update with the provided view model
    ///
    /// - Parameter viewModel: The view model to be used to update
    func update(viewModel: ViewModel)
}
