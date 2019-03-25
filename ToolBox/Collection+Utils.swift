//
//  Collection+Utils.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import Foundation

extension Collection {

    /// Safely extracts the element from index
    ///
    /// - Parameter index: The index for which to get the element
    /// - Returns: Return the value for the index or nil
    func get(_ index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// Filters the duplicates from the array of based on the provided field
    ///
    /// - Parameter field: The field to be used for filtering
    /// - Returns: The filtered array
    func filterDuplicates<T: Hashable>(byField field: (Element) -> T) -> [Element] {
        var filteredResult: [Element] = []
        var alreadyFiltered: Set<T> = Set()

        self.forEach {
            if alreadyFiltered.insert(field($0)).inserted {
                filteredResult.append($0)
            }
        }

        return filteredResult
    }
}
