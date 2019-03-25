//
//  ConfigurableHeaderFooterView.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

// MARK: - Protocols

/// The HeaderFooter view type to show in table view
protocol ConfigurableHeaderFooterViewType: Registrable {

    /// Updates the given table headerFooterView with view model
    ///
    /// - Parameter cell: The headerFooterView to be updated
    func update(headerFooter: UITableViewHeaderFooterView)
}

// MARK: - Concrete implementation

/// The concrete ConfigurableHeaderFooterViewType implementation
final class ConfigurableHeaderFooterView<HeaderFooter> : ConfigurableHeaderFooterViewType where
HeaderFooter: ViewModelUpdatable, HeaderFooter: UITableViewHeaderFooterView {

    // MARK: - TableViewRegistrable protocol conformance

    let reuseIdentifier: String = String(describing: HeaderFooter.self)

    let registerClass: AnyClass = HeaderFooter.self

    var registerNib: UINib? {
        let maineBundle = Bundle.main

        // Check if path exists and create nib
        if maineBundle.path(forResource: String(describing: HeaderFooter.self), ofType: "nib") != nil {
            return UINib(nibName: String(describing: HeaderFooter.self), bundle: nil)
        }

        return nil
    }

    // MARK: - Public properties

    /// The view model for the table view cell
    let viewModel: HeaderFooter.ViewModel

    // MARK: - Initializer

    /// Initializes a new ConfigurableTableViewRow with the provided view model.
    ///
    /// - Parameter viewModel: The view model to be used to configure the table view cell
    init(viewModel: HeaderFooter.ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - ConfigurableHeaderFooterViewType protocol conformance

    func update(headerFooter: UITableViewHeaderFooterView) {
        if let headerFooter = headerFooter as? HeaderFooter {
            headerFooter.update(viewModel: viewModel)
        }
    }
}
