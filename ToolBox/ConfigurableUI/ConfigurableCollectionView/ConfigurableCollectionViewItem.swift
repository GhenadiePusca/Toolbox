//
//  ConfigurableCollectionViewItem.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

// MARK: - Protocols

/// The table row type protocol to represent an item in collection view
protocol ConfigurableCollectionViewItemType: Registrable {

    /// The item is selected
    var onItemSelection: (() -> Void)? { get set }

    /// The view model for the current item
    var itemViewModel: Any { get }

    /// Updates the given collection view cell with view model
    ///
    /// - Parameter cell: The cell to be updated
    func update(cell: UICollectionViewCell)
}

// MARK: - Concrete implementation

/// The concrete collection view item implementation
final class ConfigurableCollectionViewItem<Item> : ConfigurableCollectionViewItemType where
Item: ViewModelUpdatable, Item: UICollectionViewCell {

    // MARK: - Properties. ConfigurableTableViewRowType protocol

    /// The reuse identifier for the cell is class name
    let reuseIdentifier: String = String(describing: Item.self)

    /// The cell class is self
    let registerClass: AnyClass = Item.self

    /// The nib extracted using class name
    var registerNib: UINib? {
        let maineBundle = Bundle.main

        // Check if path exists and create nib
        if maineBundle.path(forResource: String(describing: Item.self), ofType: "nib") != nil {
            return UINib(nibName: String(describing: Item.self), bundle: nil)
        }

        return nil
    }

    /// The view model for the item
    let viewModel: Item.ViewModel

    /// The item selection closure
    var onItemSelection: (() -> Void)?

    /// The item view model
    var itemViewModel: Any {
        return viewModel
    }

    // MARK: - Initializer

    /// Initializes a new ConfigurableCollectionViewItem with the provided view model.
    ///
    /// - Parameter viewModel: The view model to be used to configure the collection view item
    init(viewModel: Item.ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - ConfigurableTableViewRowType protocol conformance

    func update(cell: UICollectionViewCell) {
        if let cell = cell as? Item {
            cell.update(viewModel: viewModel)
        }
    }
}

