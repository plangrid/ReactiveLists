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

// MARK: - DifferenceKit Helpers

/// Creates a type-erased Differentiable for DiffableViewModel.
/// These are only created internally from either `TableCellViewModel` or `CollectionCellViewModel`,
/// so that we can safely force cast the models back to those types.
public struct AnyDiffableViewModel {

    /// The type-erased `DiffableViewModel`
    public let model: DiffableViewModel

    /// Holds implementation of `Differentiable.isContentEqual(to:)`, so that the model's concrete
    /// type can be erased
    private let isContentEqualTo: (AnyDiffableViewModel) -> Bool

    /// Initializes a `AnyDiffableViewModel` that wraps a concrete `DiffableViewModel`
    init(_ model: DiffableViewModel) {
        self.model = model

        let differenceIdentifier = model.diffingKey
        /// Only compares diff identifiers. This means we'll never get "reload"-type `Changeset`s
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

// MARK: - DifferenceKit Protocol Conformance

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
    public init<C: Swift.Collection>(source: TableSectionViewModel, elements: C) where C.Element == AnyDiffableViewModel {
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
    public init<C: Swift.Collection>(source: CollectionSectionViewModel, elements: C) where C.Element == AnyDiffableViewModel {
        self.init(
            diffingKey: source.diffingKey,
            //swiftlint:disable:next force_cast
            cellViewModels: elements.map { $0.model as! CollectionCellViewModel },
            headerViewModel: source.headerViewModel,
            footerViewModel: source.footerViewModel
        )
    }
}

// MARK: - Lazy

/// Placeholder to avoid eager-loading view models for offscreen cells
private final class DiffableTableCellViewModelProxy: TableCellViewModel {

    private static let placeholderDiffingKey = UUID().uuidString

    private let _inVisibleBounds: Bool
    private let _modelGetter: () -> TableCellViewModel

    private lazy var model = self._modelGetter()

    init(inVisibleBounds: Bool, modelGetter: @escaping () -> TableCellViewModel) {
        self._inVisibleBounds = inVisibleBounds
        self._modelGetter = modelGetter
    }

    var accessibilityFormat: CellAccessibilityFormat {
        self.model.accessibilityFormat
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        self.model.applyViewModelToCell(cell)
    }

    var registrationInfo: ViewRegistrationInfo {
        self.model.registrationInfo
    }

    var diffingKey: DiffingKey {
        if self._inVisibleBounds {
            return self.model.diffingKey
        } else {
            return Self.placeholderDiffingKey
        }
    }
}

struct DiffableTableSectionViewModel: Collection, DifferentiableSection {
    var differenceIdentifier: String { _sectionModel.differenceIdentifier }

    typealias Collection = Self
    typealias DifferenceIdentifier = String

    func isContentEqual(to source: DiffableTableSectionViewModel) -> Bool {
        self._sectionModel.isContentEqual(to: source._sectionModel)
    }

    var elements: DiffableTableSectionViewModel { self }

    typealias Element = AnyDiffableViewModel
    typealias Index = Int

    var startIndex: Int { self._sectionModel.startIndex }

    var endIndex: Int { self._sectionModel.endIndex }

    subscript(position: Int) -> AnyDiffableViewModel {
        return AnyDiffableViewModel(
            DiffableTableCellViewModelProxy(
                inVisibleBounds: self._visibleIndices.contains(position)
            ) { self._sectionModel[position] }
        )
    }

    func index(after i: Int) -> Int {
        return self._sectionModel.index(after: i)
    }

    fileprivate let _sectionModel: TableSectionViewModel

    private let _visibleIndices: Set<Int>

    var diffingKey: DiffingKey { self._sectionModel.diffingKey }

    init(sectionModel: TableSectionViewModel, visibleIndices: Set<Int>) {
        self._sectionModel = sectionModel
        self._visibleIndices = visibleIndices
    }

    init<C: Swift.Collection>(source: DiffableTableSectionViewModel, elements: C) where C.Element == AnyDiffableViewModel {
        self._sectionModel = TableSectionViewModel(
            diffingKey: source._sectionModel.diffingKey,
            cellViewModelDataSource: TableCellViewModelDataSource(
                //swiftlint:disable:next force_cast
                elements.map { $0.model as! TableCellViewModel }
            ),
            headerViewModel: source._sectionModel.headerViewModel,
            footerViewModel: source._sectionModel.footerViewModel
        )
        self._visibleIndices = source._visibleIndices
    }
}

extension Array where Element == DiffableTableSectionViewModel {
    func makeTableViewModel(sectionIndexTitles: [String]?) -> TableViewModel {
        return TableViewModel(
            sectionModels: self.map { $0._sectionModel },
            sectionIndexTitles: sectionIndexTitles
        )
    }
}
