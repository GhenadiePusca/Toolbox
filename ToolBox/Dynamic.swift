//
//  Dynamic.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import Foundation


/// Dynamic binding
final class Dynamic<T> {
    typealias Listener = (T) -> Void

    private(set) var listenersMap: [UUID: Listener] = [:]

    /// The value to be binded
    var value: T {
        didSet {
            listenersMap.values.forEach({ $0(value) })
        }
    }

    /// Creates the dynamic binding class with the passed type
    ///
    /// - Parameter v: The type to be dynamically binded
    init(_ v: T) {
        value = v
    }

    /// Binds the listener to the value
    ///
    /// Use this to bind to a value that will not outlive
    /// the listener. An example would be a value from a view model
    /// binded in the view controller - the binded value will be deallocated
    /// once the view controller is deallocated, as the view controller holds the
    /// view model
    ///
    /// - Parameter listener: The listener to bind
    func bind(_ listener: @escaping Listener) {
        bind(UUID(), listener: listener)
    }

    /// Bind the listener with the identifier, later this identifier can be used
    /// to remove the listener
    ///
    /// Use this to bind to a value that will outlive
    /// the listener. An example would be a value from a singleton service
    /// binded in the view model - the binded value will not be deallocated
    /// once the view model is deallocated, thus ensure that you will manually
    /// unbind from the value in deinit method, by calling the
    /// ubind(identifier: UUID) method.
    ///
    /// - Parameters:
    ///   - identifier: The uniques identifier for the listner
    ///   - listener: The listener to bind
    func bind(_ identifier: UUID, listener: @escaping Listener) {
        listenersMap[identifier] = listener
    }

    /// Binds the listener to the value and imediatelly notifies with value
    ///
    /// Use this to bind to a value that will not outlive
    /// the listener. An example would be a value from a view model
    /// binded in the view controller - the binded value will be deallocated
    /// once the view controller is deallocated, as the view controller holds the
    /// view model
    ///
    /// - Parameter listener: The listener to bind
    func bindAndFire(_ listener: @escaping Listener) {
        bindAndFire(UUID(), listener: listener)
    }

    /// Binds the listener with the id to the value and
    /// imediatelly notifies with value
    ///
    /// Use this to bind to a value that will outlive
    /// the listener. An example would be a value from a singleton service
    /// binded in the view model - the binded value will not be deallocated
    /// once the view model is deallocated, thus ensure that you will manually
    /// unbind from the value in deinit method, by calling the
    /// ubind(identifier: UUID) method
    ///
    /// - Parameters:
    ///   - identifier: The uniques identifier for the listner
    ///   - listener: The listener to bind
    func bindAndFire(_ identifier: UUID, listener: @escaping Listener) {
        bind(identifier, listener: listener)
        listener(value)
    }

    /// Unbind the listener for the id
    ///
    /// - Parameter identifier: The id of the listener to be unbinded
    func unbind(identifier: UUID) {
        listenersMap.removeValue(forKey: identifier)
    }
}

extension Dynamic where T: Equatable {

    /// Updates the binded value only if it did change
    ///
    /// - Parameter newValue: The value to be set
    func updateValueIfChanged(newValue: T) {
        if newValue != value {
            value = newValue
        }
    }
}
