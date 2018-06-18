//
//  PlanGrid
//  https://www.plangrid.com
//  https://medium.com/plangrid-technology
//
//  Documentation
//  https://plangrid.github.io/ReactiveLists
//
//  GitHub
//  https://github.com/plangrid/ReactiveLists
//
//  License
//  Copyright © 2018-present PlanGrid, Inc.
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import Foundation

/// A view model that can participate in an automatic diffing algorithm.
public protocol DiffableViewModel {
    /// The key used by the diffing algorithm to uniquely identify an element.
    /// If you are using automatic diffing on a `*Driver` (which is enabled by default)
    /// you are required to provide a key that uniquely identifies each element.
    ///
    /// Typically you want to base this diffing key on data that is stored in the model.
    /// For example:
    ///
    ///      public var diffingKey = { group.identifier }
    var diffingKey: DiffingKey { get }
}

/// Unique identifier for a `DiffableView`
public typealias DiffingKey = String

/// Default value for diffingKey
public extension DiffableViewModel {
    var diffingKey: DiffingKey {
        return String(describing: Self.self)
    }
}
