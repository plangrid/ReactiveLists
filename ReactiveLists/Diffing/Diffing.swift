//
//  Diffing.swift
//  ReactiveLists
//
//  Created by Benji Encz on 7/26/17.
//  Copyright © 2017 PlanGrid. All rights reserved.
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
