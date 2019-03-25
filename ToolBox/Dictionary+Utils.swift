//
//  Dictionary+Utils.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import Foundation

extension Dictionary {

    /// Gets the value for the key if it does exist
    ///
    /// - Parameter key: The Key to get value for
    /// - Returns: The value if it exist
    func getValue<T>(key: Key) -> T? {
        return self[key] as? T
    }

    /// Gets the array value for the key if it does exist
    ///
    /// - Parameter key: The Key to get value for
    /// - Returns: The array value if it exist
    func getArray<Type>(key: Key) -> [Type] {
        return self[key] as? [Type] ?? []
    }
}
