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

import UIKit

// MARK: - CollectionCellViewModel

/// View model for the individual cells of a `UICollectionView`.
public protocol CollectionCellViewModel: ReusableCellViewModelProtocol, DiffableViewModel {

    /// `CollectionViewDriver` will automatically apply an `accessibilityIdentifier` to the cell based on this format
    var accessibilityFormat: CellAccessibilityFormat { get }

    /// Whether or not this cell should be highlighted.
    var shouldHighlight: Bool { get }

    /// Invoked when a cell has been selected.
    var didSelect: DidSelectClosure? { get }

    /// Invoked when an accessory button is tapped.
    var didDeselect: DidDeselectClosure? { get }

    /// Asks the cell model to update the `UICollectionViewCell` with the content
    /// in the cell model and return the updated cell.
    /// - Parameter cell: the cell which's content need to be updated.
    func applyViewModelToCell(_ cell: UICollectionViewCell)
    
    /// Invoke when  a cell will be displayed
    func willDisplay(cell: UICollectionViewCell)
}

/// Default implementations for `CollectionCellViewModel`.
extension CollectionCellViewModel {

    /// Default implementation, returns `true`.
    public var shouldHighlight: Bool { return true }

    /// Default implementation, returns `nil`.
    public var didSelect: DidSelectClosure? { return nil }

    /// Default implementation, returns `nil`.
    public var didDeselect: DidDeselectClosure? { return nil }
    
    /// Default implementation, returns `nil`.
    public func willDisplay(cell: UICollectionViewCell) { }
}

/// A `FlowLayoutCollectionCellViewModel` is a `CollectionCellViewModel` that will be placed in its
/// collection view using a `UICollectionViewFlowLayout`. This allows it to provide a dynamic item
/// size that can take into account its container size and other layout information.
public protocol FlowLayoutCollectionCellViewModel: CollectionCellViewModel {

    /// When using this cell inside of a `UICollectionViewFlowLayout`, this hook can be used to
    /// size this cell.
    ///
    /// - Parameters:
    ///   - collectionView: The parent `UICollectionView` of this cell.
    ///   - layout: The `UICollectionViewFlowLayout` that will layout this cell.
    ///   - indexPath: The path at which this item is positioned in `collectionView`.
    /// - Returns:
    ///   The width and height of the specified item. Both values should be greater than 0.
    func itemSize(
        in collectionView: UICollectionView,
        layout: UICollectionViewFlowLayout,
        indexPath: IndexPath
    ) -> CGSize
}

// MARK: - CollectionSupplementaryViewModel

/// View model for supplementary views in collection views.
public protocol CollectionSupplementaryViewModel: ReusableSupplementaryViewModelProtocol {

    /// Metadata for this supplementary view.
    var viewInfo: SupplementaryViewInfo? { get }

    /// Height of this supplementary view.
    var height: CGFloat? { get }

    /// Asks the supplementary view model to update the `UICollectionReusableView` with the content
    /// in the model and return the updated view.
    /// - Parameter view: the view which's content need to be update.
    func applyViewModelToView(_ view: UICollectionReusableView)
}

/// Default implementations for `CollectionViewSupplementaryViewModel`.
extension CollectionSupplementaryViewModel {

    /// Default implementation, returns `nil`.
    public var viewInfo: SupplementaryViewInfo? { return nil }

    /// Default implementation, returns `nil`.
    public var height: CGFloat? { return nil }
}

// MARK: - CollectionViewModel

/// The view model that describes a `UICollectionView`.
public struct CollectionViewModel {

    /// The section view models for this collection view.
    public let sectionModels: [CollectionSectionViewModel]

    /// Returns `true` if this collection has all empty sections.
    public var isEmpty: Bool {
        return self.sectionModels.allSatisfy { $0.isEmpty }
    }

    /// Initializes a collection view model with the sections provided.
    ///
    /// - Parameter sectionModels: the sections that need to be shown in this collection view.
    public init(sectionModels: [CollectionSectionViewModel]) {
        self.sectionModels = sectionModels
    }

    /// Returns the section model at the specified index or `nil` if no such section exists.
    ///
    /// - Parameter section: the index for the section that is being retrieved
    public subscript(ifExists section: Int) -> CollectionSectionViewModel? {
        guard self.sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    /// Returns the cell view model at the specified index path or `nil` if no such cell exists.
    ///
    /// - Parameter indexPath: the index path for the cell that is being retrieved
    public subscript(ifExists indexPath: IndexPath) -> CollectionCellViewModel? {
        guard let section = self[ifExists: indexPath.section] else { return nil }

        if let dataSource = section.cellViewModelDataSource {
            guard indexPath.count >= 2, // In rare cases, we've seen UIKit give us a bad IndexPath
                  dataSource.count > indexPath.row else { return nil }
            return dataSource[indexPath.row]
        } else {
            guard section.cellViewModels.count > indexPath.item else { return nil }
            return section.cellViewModels[indexPath.item]
        }
    }
    
    /// A view of `TableSectionViewModel` used for diffing
    func sectionModelsForDiffing(inVisibleIndexPaths visibleIndexPaths: [IndexPath]) -> [DiffableCollectionSectionViewModel] {
        let visibleIndicesBySection = [Int: AnySequence<Int>](
            uniqueKeysWithValues: visibleIndexPaths.indicesBySection()
        ).mapValues { Set($0) }
        return zip(sectionModels, sectionModels.indices).map { sectionModel, section in
            DiffableCollectionSectionViewModel(
                sectionModel: sectionModel,
                visibleIndices: visibleIndicesBySection[section, default: Set<Int>()]
            )
        }
    }
}

// MARK: - CollectionSectionViewModel

/// View model for a collection view section.
public struct CollectionSectionViewModel: DiffableViewModel {

    /// Cells to be shown in this section.
    let cellViewModels: [CollectionCellViewModel]

    /// Datasource for the cells to be shown in this section.
    public let cellViewModelDataSource: CollectionCellViewModelDataSource?

    /// View model for the header of this section.
    let headerViewModel: CollectionSupplementaryViewModel?

    /// View model for the footer of this section.
    let footerViewModel: CollectionSupplementaryViewModel?

    /// The key used by the diffing algorithm to uniquely identify this section.
    /// If you are using automatic diffing on the `CollectionViewDriver` (which is enabled by default)
    /// you are required to provide a key that uniquely identifies this section.
    ///
    /// Typically you want to base this diffing key on data that is stored in the model.
    /// For example:
    ///
    ///      public var diffingKey = { group.identifier }
    public var diffingKey: String

    /// Returns `true` if this section has zero cell view models, `false` otherwise.
    public var isEmpty: Bool {
        if let cellDataSource = self.cellViewModelDataSource {
            return cellDataSource.isEmpty
        }
        return self.cellViewModels.isEmpty
    }

    /// Initializes a collection view section view model.
    ///
    /// - Parameters:
    ///   - diffingKey: a `String` key unique to this section that is used to diff sections
    ///     automatically. Pass in `nil` if you are not using automatic diffing on this collection.
    ///   - cellViewModels: the cells in this section.
    ///   - headerViewModel: the header view model (defaults to `nil`).
    ///   - footerViewModel: the footer view model (defaults to `nil`).
    public init(
        diffingKey: String?,
        cellViewModels: [CollectionCellViewModel],
        cellViewModelDataSource: CollectionCellViewModelDataSource? = nil,
        headerViewModel: CollectionSupplementaryViewModel? = nil,
        footerViewModel: CollectionSupplementaryViewModel? = nil
    ) {
        self.cellViewModels = cellViewModels
        self.cellViewModelDataSource = cellViewModelDataSource
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.diffingKey = diffingKey ?? UUID().uuidString
    }
}

/// `Collection` support for diffing
extension CollectionSectionViewModel: Collection {
    /// :nodoc:
    public subscript(position: Int) -> CollectionCellViewModel {
        if let dataSource = self.cellViewModelDataSource {
            return dataSource[position]
        }
        return self.cellViewModels[position]
    }

    /// :nodoc:
    public func index(after i: Int) -> Int {
        if let dataSource = self.cellViewModelDataSource {
            return dataSource.index(after: i)
        }
        return self.cellViewModels.index(after: i)
    }

    /// :nodoc:
    public var startIndex: Int {
        if let dataSource = self.cellViewModelDataSource {
            return dataSource.startIndex
        }
        return self.cellViewModels.startIndex
    }

    /// :nodoc:
    public var endIndex: Int {
        if let dataSource = self.cellViewModelDataSource {
            return dataSource.endIndex
        }
        return self.cellViewModels.endIndex
    }
}
