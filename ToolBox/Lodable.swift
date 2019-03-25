//
//  Loadable.swift
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

import Foundation

/// Describes the state of the data
///
/// - initial: Initialized state
/// - loading: The data is loading
/// - value: The data did load
/// - error: An error occured while loading
enum Loadable<T> {
    case initial
    case loading
    case value(T)
    case error(Error)

    /// The state is initial
    var isInitial: Bool {
        guard case .initial = self else {
            return false
        }
        return true
    }

    /// Is the state loading
    var isLoading: Bool {
        guard case .loading = self else {
            return false
        }
        return true
    }

    /// Get the data if any
    var data: T? {
        guard case .value(let data) = self else {
            return nil
        }

        return data
    }

    /// Is data loaded successfully
    var isSuccess: Bool {
        guard case .value(_) = self else {
            return false
        }

        return true
    }

    /// Get the error if any
    var error: Error? {
        guard case .error(let error) = self else {
            return nil
        }

        return error
    }

    /// Pipes the current loadable to another loadable using pipe method
    ///
    /// - Parameter pipe: pipe method to pipe to another loadable
    /// - Returns: The piped loadable
    public func pipeTo<V>(with pipe: (T) -> V) -> Loadable<V> {
        switch self {
        case .initial:
            return Loadable<V>.initial
        case .loading:
            return Loadable<V>.loading
        case .value(let data):
            return Loadable<V>.value(pipe(data))
        case .error(let error):
            return Loadable<V>.error(error)
        }
    }

    /// Compares the curent state to another loadable state
    ///
    /// - Parameters:
    ///   - loadable: The loadable state to compare to
    ///   - compare: The compare operation to be applied if both state have value
    /// - Returns: The flag indicating if the two loadable states are equal
    func isEqual(to loadable: Loadable<T>, compare: (T, T) -> Bool) -> Bool {
        switch (self, loadable) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case let (.value(lhsData), .value(rhsData)):
            return compare(lhsData, rhsData)
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}

struct LoadableCombine {

    /// Combines 2 loadables in one
    ///
    /// To be successfull, both loadable should have succesfful state.
    /// If at least one is failed, the combination is failed
    /// If one is loading and another is not error, the combination is loading.
    /// If one is initial and another have value, the combination is initial
    ///
    /// - Parameters:
    ///   - one: First loadable
    ///   - two: Second loadable
    /// - Returns: Combine state
    static func combine<T, V>(_ one: Loadable<T>, _ two: Loadable<V>) -> Loadable<(T, V)> {
        switch (one, two) {
        case (.error(let error), _),
             (_, .error(let error)):
            return Loadable<(T, V)>.error(error)
        case (.loading, _),
             (_, .loading):
            return Loadable<(T, V)>.loading
        case (.initial, _),
             (_, .initial):
            return Loadable<(T, V)>.initial
        case let (.value(oneData),
                  .value(twoData)):
            return Loadable<(T, V)>.value((oneData, twoData))
        }
    }

    /// Combines 3 loadables in one
    ///
    /// To be successfull, all loadables should have succesfful state.
    /// If at least one is failed, the combination is failed
    /// If all are loading, the combination is loading.
    /// If all are initial, the combination is initial
    ///
    /// - Parameters:
    ///   - one: First loadable
    ///   - two: Second loadable
    ///   - three: Third loadable
    /// - Returns: The combined loadable
    static func combine3<T, V, P>(_ one: Loadable<T>,
                                  _ two: Loadable<V>,
                                  _ three: Loadable<P>) -> Loadable<(T, V, P)> {
        switch (one, two, three) {
        case (.error(let error), _, _),
             (_, .error(let error), _),
             (_, _, .error(let error)):
            return Loadable<(T, V, P)>.error(error)
        case (.loading, _, _),
             (_, .loading, _),
             (_, _, .loading):
            return Loadable<(T, V, P)>.loading
        case (.initial, _, _),
             (_, .initial, _),
             (_, _, .initial):
            return Loadable<(T, V, P)>.initial
        case let (.value(oneData),
                  .value(twoData),
                  .value(threeData)):
            return Loadable<(T, V, P)>.value((oneData, twoData, threeData))
        }
    }

    /// Combines 4 loadables in one
    ///
    /// To be successfull, all loadables should have succesfful state.
    /// If at least one is failed, the combination is failed
    /// If all are loading, the combination is loading.
    /// If all are initial, the combination is initial
    ///
    /// - Parameters:
    ///   - one: First loadable
    ///   - two: Second loadable
    ///   - three: Third loadable
    ///   - four: The fourth loadable
    /// - Returns: The combined loadable
    static func combine4<X, V, P, M>(_ one: Loadable<X>,
                                     _ two: Loadable<V>,
                                     _ three: Loadable<P>,
                                     _ four: Loadable<M>) -> Loadable<(X, V, P, M)> {
        switch (one, two, three, four) {
        case (.error(let error), _, _, _),
             (_, .error(let error), _, _),
             (_, _, .error(let error), _),
             (_, _, _, .error(let error)):
            return Loadable<(X, V, P, M)>.error(error)
        case (.loading, _, _, _),
             (_, .loading, _, _),
             (_, _, .loading, _),
             (_, _, _, .loading):
            return Loadable<(X, V, P, M)>.loading
        case (.initial, _, _, _),
             (_, .initial, _, _),
             (_, _, .initial, _),
             (_, _, _, .initial):
            return Loadable<(X, V, P, M)>.initial
        case let (.value(oneData),
                  .value(twoData),
                  .value(threeData),
                  .value(fourData)):
            return Loadable<(X, V, P, M)>.value((oneData, twoData, threeData, fourData))
        }
    }
}
