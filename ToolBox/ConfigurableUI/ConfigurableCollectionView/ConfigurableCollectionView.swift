//
//  ConfigurableCollectionView.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import UIKit

/// The configurable collection view
final class ConfigurableCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    /// The section data to configure the collection view
    let sectionData: Dynamic<[[ConfigurableCollectionViewItemType]]> = Dynamic([])

    // MARK: - Initializers

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    // MARK: - Private methods

    /// Prepares the collection view to be used
    private func initialSetup() {
        delegate = self
        dataSource = self
        sectionData.bindAndFire { [weak self] _ in
            self?.registerCells()
            self?.reloadData()
        }
    }

    /// Register the cells to be used in table view
    private func registerCells() {
        // Get all rows from the section data
        let allRows = sectionData.value.flatMap { $0 }

        // Filter duplicates based on reuseIndentifier
        let filteredRows = allRows.filterDuplicates(byField: { $0.reuseIdentifier })

        // Register the cells
        for rowData in filteredRows {
            if let nib = rowData.registerNib {
                register(nib, forCellWithReuseIdentifier: rowData.reuseIdentifier)
            } else {
                register(rowData.registerClass, forCellWithReuseIdentifier: rowData.reuseIdentifier)
            }
        }
    }

    // MARK: - UICollectionViewDataSource conformance

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionData.value.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionData.value.get(section)?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellConfigurator = sectionData.value.get(indexPath.section)?.get(indexPath.row) else {
            return UICollectionViewCell()
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellConfigurator.reuseIdentifier,
                                                      for: indexPath)
        cellConfigurator.update(cell: cell)

        return cell
    }

    // MARK: - UICollectionViewDelegate conformance

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sectionData.value.get(indexPath.section)?.get(indexPath.row)?.onItemSelection?()
    }
}
