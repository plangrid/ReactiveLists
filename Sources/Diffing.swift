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

/// Placeholder to avoid eager-loading view models for offscreen cells,
/// which the data source may not have loaded
private final class DiffableTableCellViewModelProxy: TableCellViewModel {

    /// Static diffing key used when diffing off-screen models
    private static let placeholderDiffingKey = UUID().uuidString

    /// When true, we allow diffing to access the real model's diffing key, eagerly loading it
    private let _inVisibleBounds: Bool

    /// Lambda to load the model
    private let _modelGetter: () -> TableCellViewModel

    /// Lazy reference to the model
    private lazy var model = self._modelGetter()

    init(inVisibleBounds: Bool, modelGetter: @escaping () -> TableCellViewModel) {
        self._inVisibleBounds = inVisibleBounds
        self._modelGetter = modelGetter
    }

    /// Only accessed during display, so eager-loading is allowed here
    var accessibilityFormat: CellAccessibilityFormat {
        self.model.accessibilityFormat
    }

    /// Only called during display, so eager-loading is allowed here
    func applyViewModelToCell(_ cell: UITableViewCell) {
        self.model.applyViewModelToCell(cell)
    }

    /// Only accessed during display, so eager-loading is allowed here
    var registrationInfo: ViewRegistrationInfo {
        self.model.registrationInfo
    }

    /// Only allows accessing the real model's diffing key for visible models
    var diffingKey: DiffingKey {
        if self._inVisibleBounds {
            return self.model.diffingKey
        } else {
            return Self.placeholderDiffingKey
        }
    }
}

/// A `DifferentiableSection` that ensures we only allow eager-loading
/// of cells that are known to be on-screen, which avoids forcing
/// a datasource to potentially load data that hasn't been loaded yet
/// to create new cell models (expensive)
struct DiffableTableSectionViewModel: Collection, DifferentiableSection {

    /// Reference to the original `TableSectionViewModel`
    fileprivate let _sectionModel: TableSectionViewModel

    /// The set of indices in this section, for which we should allow
    /// diffing to access, since these cells are visible (i.e. won't
    /// eagerly load data that the data source may not have loaded)
    private let _visibleIndices: Set<Int>

    /// Initializes a `DiffableTableSectionViewModel` with the
    /// section model and visibile indices in this section
    init(sectionModel: TableSectionViewModel, visibleIndices: Set<Int>) {
        self._sectionModel = sectionModel
        self._visibleIndices = visibleIndices
    }

    /// MARK: - Protocol Implementations

    /// :nodoc:
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

    /// :nodoc:
    var diffingKey: DiffingKey { self._sectionModel.diffingKey }

    /// :nodoc:
    var differenceIdentifier: String { _sectionModel.differenceIdentifier }

    /// :nodoc:
    typealias Collection = Self

    /// :nodoc:
    typealias DifferenceIdentifier = String

    /// :nodoc:
    func isContentEqual(to source: DiffableTableSectionViewModel) -> Bool {
        self._sectionModel.isContentEqual(to: source._sectionModel)
    }

    /// :nodoc:
    var elements: DiffableTableSectionViewModel { self }

    /// :nodoc:
    typealias Element = AnyDiffableViewModel

    /// :nodoc:
    typealias Index = Int

    /// :nodoc:
    var startIndex: Int { self._sectionModel.startIndex }

    /// :nodoc:
    var endIndex: Int { self._sectionModel.endIndex }

    /// :nodoc:
    subscript(position: Int) -> AnyDiffableViewModel {
        return AnyDiffableViewModel(
            DiffableTableCellViewModelProxy(
                inVisibleBounds: self._visibleIndices.contains(position)
            ) { self._sectionModel[position] }
        )
    }

    /// :nodoc:
    func index(after i: Int) -> Int {
        return self._sectionModel.index(after: i)
    }
}

extension Array where Element == DiffableTableSectionViewModel {

    /// Creates a new `TableViewModel` from a `[DiffableTableSectionViewModel]`
    /// for diffing
    func makeTableViewModel(sectionIndexTitles: [String]?) -> TableViewModel {
        return TableViewModel(
            sectionModels: self.map { $0._sectionModel },
            sectionIndexTitles: sectionIndexTitles
        )
    }
}
