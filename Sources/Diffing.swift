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

/// A view that can participate in an automatic diffing algorithm.
public protocol DiffableViewModel {
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
