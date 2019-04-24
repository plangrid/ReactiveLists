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

import DifferenceKit
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
extension DiffableViewModel {

    /// Default implementation. Uses class name.
    public var diffingKey: DiffingKey {
        return String(describing: Self.self)
    }
}

/// MARK: - DifferenceKit Helpers

/// Creates a type-erased Differentiable for DiffableViewModel.
/// These are only created internally from either `TableCellViewModel` or `CollectionCellViewModel`,
/// so that we can safely force cast the models back to those types.
public struct AnyDiffableViewModel {

    /// The type-erased `DiffableViewModel`
    public let model: DiffableViewModel

    /// Holds implementation of `Differentiable.isContentEqual(to:)`, so that the model's concrete
    /// type can be erased
    private let isContentEqualTo: (AnyDiffableViewModel) -> Bool

    /// Initializes a `AnyDiffableViewModel` that wraps a `TableCellViewModel`
    init(_ model: TableCellViewModel) {
        self.model = model

        let differenceIdentifier = model.diffingKey
        /// Only compares diff identifiers. This means we'll never get "reload"-type `Changeset`s
        self.isContentEqualTo = { source in
            return differenceIdentifier == source.differenceIdentifier
        }
    }

    /// Initializes a `AnyDiffableViewModel` that wraps a `TableCellViewModel`
    init(_ model: CollectionCellViewModel) {
        self.model = model

        let differenceIdentifier = model.diffingKey
        self.isContentEqualTo = { source in
            return differenceIdentifier == source.differenceIdentifier
        }
    }
}

extension AnyDiffableViewModel: Differentiable {

    /// :nodoc:
    public var differenceIdentifier: DiffingKey {
        return self.model.diffingKey
    }

    /// :nodoc:
    public func isContentEqual(to source: AnyDiffableViewModel) -> Bool {
        return self.isContentEqualTo(source)
    }
}

/// MARK: - DifferenceKit Protocol Conformance

extension TableSectionViewModel: DifferentiableSection {

    // MARK: Differentiable Conformance

    /// :nodoc:
    public var differenceIdentifier: DiffingKey {
        return self.diffingKey
    }

    /// :nodoc:
    public func isContentEqual(to source: TableSectionViewModel) -> Bool {
        return self.diffingKey == source.diffingKey
    }

    // MARK: DifferentiableSection Conformance

    /// :nodoc:
    public var elements: [AnyDiffableViewModel] {
        return self.map { AnyDiffableViewModel($0) }
    }

    /// :nodoc:
    public init<C: Collection>(source: TableSectionViewModel, elements: C) where C.Element == AnyDiffableViewModel {
        self.init(
            diffingKey: source.diffingKey,
            //swiftlint:disable:next force_cast
            cellViewModels: elements.map { $0.model as! TableCellViewModel },
            headerViewModel: source.headerViewModel,
            footerViewModel: source.footerViewModel
        )
    }
}

extension CollectionSectionViewModel: DifferentiableSection {

    // MARK: Differentiable Conformance

    /// :nodoc:
    public var differenceIdentifier: DiffingKey {
        return self.diffingKey
    }

    /// :nodoc:
    public func isContentEqual(to source: CollectionSectionViewModel) -> Bool {
        return self.diffingKey == source.diffingKey
    }

    // MARK: DifferentiableSection Conformance

    /// :nodoc:
    public var elements: [AnyDiffableViewModel] {
        return self.map { AnyDiffableViewModel($0) }
    }

    /// :nodoc:
    public init<C: Collection>(source: CollectionSectionViewModel, elements: C) where C.Element == AnyDiffableViewModel {
        self.init(
            diffingKey: source.diffingKey,
            //swiftlint:disable:next force_cast
            cellViewModels: elements.map { $0.model as! CollectionCellViewModel },
            headerViewModel: source.headerViewModel,
            footerViewModel: source.footerViewModel
        )
    }
}
