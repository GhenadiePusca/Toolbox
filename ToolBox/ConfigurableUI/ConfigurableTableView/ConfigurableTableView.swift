//
//  ConfigurableTableView.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

/// The generic configurable table view
final class ConfigurableTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    /// The view model of the table view
    let tableData = Dynamic<[ConfigurableTableViewSection]>([])

    // MARK: - Initialization

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }

    // MARK: - Setup

    /// Performs the initialSetup
    private func initialSetup() {
        delegate = self
        dataSource = self

        // By default the header is hidden, it should be setup externally on need
        tableHeaderView = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: CGFloat.leastNonzeroMagnitude,
                                               height: CGFloat.leastNonzeroMagnitude))

        tableData.bindAndFire{ [weak self] _ in
            self?.registerCells()
            self?.registerHeaderFooterViews()
            self?.registerForReloads()
            self?.reloadData()
        }
    }

    /// Register the cells to be used in table view
    private func registerCells() {
        // Get all rows from the table data
        let allRows = tableData.value.flatMap { $0.rows }

        // Filter duplicates based on reuseIndentifier
        let filteredRows = allRows.filterDuplicates(byField: { $0.reuseIdentifier })

        // Register the cells
        for rowData in filteredRows {
            if let nib = rowData.registerNib {
                register(nib, forCellReuseIdentifier: rowData.reuseIdentifier)
            } else {
                register(rowData.registerClass, forCellReuseIdentifier: rowData.reuseIdentifier)
            }
        }
    }

    /// Registers the header footer views
    private func registerHeaderFooterViews() {
        // Get all rows from the table data
        let allHeaders = tableData.value.compactMap { $0.headerViewConfigurator }
        let allFooters = tableData.value.compactMap { $0.headerViewConfigurator }

        // Filter duplicates based on reuseIndentifier
        let filteredHeaders = allHeaders.filterDuplicates(byField: { $0.reuseIdentifier })
        let filteredFooters = allFooters.filterDuplicates(byField: { $0.reuseIdentifier })

        registerHeaderFooterViews(configurators: filteredHeaders)
        registerHeaderFooterViews(configurators: filteredFooters)
    }

    /// Registers the header footer views from the provided configurators
    ///
    /// - Parameter configurators: The configurators to use to perform register
    private func registerHeaderFooterViews(configurators: [ConfigurableHeaderFooterViewType]) {
        for config in configurators {
            if let nib = config.registerNib {
                register(nib, forHeaderFooterViewReuseIdentifier: config.reuseIdentifier)
            } else {
                register(config.registerClass, forHeaderFooterViewReuseIdentifier: config.reuseIdentifier)
            }
        }
    }

    /// Register for the row reload request
    private func registerForReloads() {
        for section in 0..<tableData.value.count {
            for row in 0..<tableData.value[section].rows.count {
                var config = tableData.value[section].rows[row]
                config.reloadRow = { [weak self] in
                    self?.reloadRow(at: IndexPath(row: row, section: section))
                }
            }
        }
    }

    /// Reloads row ad index path
    ///
    /// - Parameter indexPath: The indexPath to reload the row for
    private func reloadRow(at indexPath: IndexPath) {
        beginUpdates()
        reloadRows(at: [indexPath], with: .automatic)
        endUpdates()
    }

    // MARK: UITableViewDataSource protocol

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.value.get(section)?.rows.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellConfigurator = tableData.value.get(indexPath.section)?.rows.get(indexPath.row) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellConfigurator.reuseIdentifier, for: indexPath)
        cellConfigurator.update(cell: cell)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let config = tableData.value.get(section)?.headerViewConfigurator else {
            return nil
        }

        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: config.reuseIdentifier) else {
            return nil
        }

        config.update(headerFooter: header)

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let config = tableData.value.get(section)?.footerViewConfigurator else {
            return nil
        }

        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: config.reuseIdentifier) else {
            return nil
        }

        config.update(headerFooter: footer)

        return footer
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData.value.get(section)?.headerTitle
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableData.value.get(section)?.footerTitle
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableData.value.get(indexPath.section)?.rows.get(indexPath.row)?.canEdit ?? false
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tableData.value.get(indexPath.section)?.rows.get(indexPath.row)?.onRowSelection?()
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableData.value.get(indexPath.section)?.rows.get(indexPath.row)?.onDelete?()
        }
    }
}

