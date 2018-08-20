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
public extension DiffableViewModel {

    /// Default implementation. Uses class name.
    var diffingKey: DiffingKey {
        return String(describing: Self.self)
    }
}

/// MARK: - DifferenceKit Helpers

/// Creates a type-erased Differentiable for DiffableViewModel.
/// These are only created internally from either `TableCellViewModel` or `CollectionCellViewModel`,
/// so that we can safely force cast the models back to those types.
public struct AnyDiffableViewModel {
    public let model: DiffableViewModel

    private let isContentEqualTo: (AnyDiffableViewModel) -> Bool

    init(_ model: TableCellViewModel) {
        self.model = model

        let differenceIdentifier = model.diffingKey
        /// Only compares diff identifiers. This means we'll never get "reload"-type `Changeset`s
        self.isContentEqualTo = { source in
            return differenceIdentifier == source.differenceIdentifier
        }
    }

    init(_ model: CollectionCellViewModel) {
        self.model = model

        let differenceIdentifier = model.diffingKey
        self.isContentEqualTo = { source in
            return differenceIdentifier == source.differenceIdentifier
        }
    }
}

extension AnyDiffableViewModel: Differentiable {

    public var differenceIdentifier: DiffingKey {
        return self.model.diffingKey
    }

    public func isContentEqual(to source: AnyDiffableViewModel) -> Bool {
        return self.isContentEqualTo(source)
    }
}

/// Wraps a `DifferentiableSection` that is a `DiffableViewModel`, so that
/// `DifferentalSection`-types don't have to implement `Differentiable`, which would lead to an
/// ambiguous type check for the correct initializer for `StagedChangeset`
public struct DifferentiableSectionModel<D: DiffableViewModel & DifferentiableSection> {
    let model: D

    private let isContentEqualTo: (DifferentiableSectionModel) -> Bool

    init(_ model: D) {
        self.model = model
        let differenceIdentifier = model.diffingKey
        self.isContentEqualTo = { source in
            return differenceIdentifier == source.differenceIdentifier
        }
    }
}

extension DifferentiableSectionModel: Differentiable {

    public var differenceIdentifier: DiffingKey {
        return self.model.diffingKey
    }

    public func isContentEqual(to source: DifferentiableSectionModel) -> Bool {
        return self.isContentEqualTo(source)
    }
}

/// MARK: - DifferenceKit Protocol Conformance

extension TableSectionViewModel: DifferentiableSection {

    public var model: DifferentiableSectionModel<TableSectionViewModel> {
        return DifferentiableSectionModel(self)
    }

    public var elements: [AnyDiffableViewModel] {
        return self.map { AnyDiffableViewModel($0) }
    }

    public init<C>(model: DifferentiableSectionModel<TableSectionViewModel>, elements: C) where C: Collection, C.Element == AnyDiffableViewModel {
        let sectionModel = model.model
        self.init(
            //swiftlint:disable:next force_cast
            cellViewModels: elements.map { $0.model as! TableCellViewModel },
            headerViewModel: sectionModel.headerViewModel,
            footerViewModel: sectionModel.footerViewModel,
            diffingKey: sectionModel.diffingKey
        )
    }
}

extension CollectionSectionViewModel: DifferentiableSection {

    public var model: DifferentiableSectionModel<CollectionSectionViewModel> {
        return DifferentiableSectionModel(self)
    }

    public var elements: [AnyDiffableViewModel] {
        return self.map { AnyDiffableViewModel($0) }
    }

    public init<C>(model: DifferentiableSectionModel<CollectionSectionViewModel>, elements: C) where C: Collection, C.Element == AnyDiffableViewModel {
        let sectionModel = model.model
        self.init(
            //swiftlint:disable:next force_cast
            cellViewModels: elements.map { $0.model as! CollectionCellViewModel },
            headerViewModel: sectionModel.headerViewModel,
            footerViewModel: sectionModel.footerViewModel,
            diffingKey: sectionModel.diffingKey
        )
    }
}
