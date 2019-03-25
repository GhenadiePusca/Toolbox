//
//  ConfigurableTableViewRow.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

// MARK: - Protocols

/// The table row type protocol to represent a row in a table view
protocol ConfigurableTableViewRowType: Registrable {
    /// The table view cell was selected
    var onRowSelection: (() -> Void)? { get set }

    /// The delete button for the cell is tapped
    var onDelete: (() -> Void)? { get set }

    /// The view model for the current cell
    var cellViewModel: Any { get }

    /// The row can be edited or not
    var canEdit: Bool { get }

    /// Performs the row reload
    var reloadRow: (() -> Void)? { get set}

    /// Updates the given table view cell with view model
    ///
    /// - Parameter cell: The cell to be updated
    func update(cell: UITableViewCell)
}

// MARK: - Concrete implementation

/// The concrete table view row implementation
final class ConfigurableTableViewRow<Row> : ConfigurableTableViewRowType where
Row: ViewModelUpdatable, Row: UITableViewCell {

    // MARK: - Properties. ConfigurableTableViewRowType protocol

    /// The reuse identifier for the cell is class name
    let reuseIdentifier: String = String(describing: Row.self)

    /// The table view cell class is self
    let registerClass: AnyClass = Row.self

    /// The nib extracted using class name
    var registerNib: UINib? {
        let maineBundle = Bundle.main

        // Check if path exists and create nib
        if maineBundle.path(forResource: String(describing: Row.self), ofType: "nib") != nil {
            return UINib(nibName: String(describing: Row.self), bundle: nil)
        }

        return nil
    }

    /// The view model for the table view cell
    let viewModel: Row.ViewModel

    /// The row selection closure
    var onRowSelection: (() -> Void)?

    /// The row delete button closure
    var onDelete: (() -> Void)?

    /// Performs the row reload
    var reloadRow: (() -> Void)?

    /// The row can be edited or not
    var canEdit: Bool = false

    /// The cell view model
    var cellViewModel: Any {
        return viewModel
    }

    // MARK: - Initializer

    /// Initializes a new ConfigurableTableViewRow with the provided view model.
    ///
    /// - Parameter viewModel: The view model to be used to configure the table view cell
    init(viewModel: Row.ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - ConfigurableTableViewRowType protocol conformance

    func update(cell: UITableViewCell) {
        if let cell = cell as? Row {
            cell.update(viewModel: viewModel)
        }
    }
}

