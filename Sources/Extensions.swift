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

import ReactiveSwift

let uiScheduler = UIScheduler()

extension Signal {
    /// All events are observed on the main queue (UI thread)
    func onMainQueue() -> Signal<Value, Error> {
        return self.observe(on: uiScheduler)
    }
}

extension SignalProducer {
    /// All events are observed on the main queue (UI thread)
    func onMainQueue() -> SignalProducer<Value, Error> {
        return self.observe(on: uiScheduler)
    }
}

extension Collection where Index: Strideable {
    /// Safely subscript the collection, returning `nil` if the index is out of bounds
    ///
    /// - parameter ifExists: the index to subscript.
    /// - returns: The element at the given index, or `nil` if the index is out of bounds
    ///
    /// - note: This version is guaranteed to have `O(1)` complexity.
    subscript(ifExists index: Self.Index) -> Self.Element? {
        return index >= self.startIndex && index < self.endIndex ? self[index] : nil
    }
}
