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

import Dwifft
import UIKit

/// View model for the individual cells of a `UICollectionView`.
public protocol CollectionCellViewModel: ReusableCellViewModelProtocol {

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
}

/// Default implementations for `CollectionViewCellViewModel`.
public extension CollectionCellViewModel {
    var shouldHighlight: Bool { return true }
    var didSelect: DidSelectClosure? { return nil }
    var didDeselect: DidDeselectClosure? { return nil }
}

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
public extension CollectionSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { return nil }
    var height: CGFloat? { return nil }

    func applyViewModelToView(_ view: UICollectionReusableView) {}
}

/// The view model that describes a `UICollectionView`.
public struct CollectionViewModel {

    /// The section view models for this collection view.
    public let sectionModels: [CollectionSectionViewModel]

    /// Initializes a collection view model with the sections provided.
    ///
    /// - Parameter sectionModels: the sections that need to be shown in this collection view.
    public init(sectionModels: [CollectionSectionViewModel]) {
        self.sectionModels = sectionModels
    }

    /// Returns the section model at the specified index or `nil` if no such section exists.
    ///
    /// - Parameter section: the index for the section that is being retrieved
    public subscript(section: Int) -> CollectionSectionViewModel? {
        guard self.sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    /// Returns the cell view model at the specified index path or `nil` if no such cell exists.
    ///
    /// - Parameter indexPath: the index path for the cell that is being retrieved
    public subscript(indexPath: IndexPath) -> CollectionCellViewModel? {
        guard let section = self[indexPath.section], section.cellViewModels.count > indexPath.item else { return nil }
        return section.cellViewModels[indexPath.item]
    }

    /// Provides a description of the collection view content in terms of diffing keys. These diffing keys
    /// are used to calculate changesets in the collection and animate changes automatically.
    var diffingKeys: SectionedValues<DiffingKey, DiffingKey> {
        return SectionedValues(
            self.sectionModels.map { section in
                // Ensure we have a diffing key for the current section
                guard let sectionDiffingKey = section.diffingKey else {
                    fatalError("When diffing is enabled you need to provide a non-nil diffingKey for each section.")
                }

                // Ensure we have a diffing key for each cell in this section
                let cellDiffingKeys: [DiffingKey] = section.cellViewModels.map { cell in
                    guard let cell = cell as? DiffableViewModel else {
                        fatalError("When diffing is enabled you need to provide cells which are DiffableViews.")
                    }
                    return "\(type(of: cell))_\(cell.diffingKey)"
                }

                return (sectionDiffingKey, cellDiffingKeys)
            }
        )
    }
}

/// View model for a collection view section.
public struct CollectionSectionViewModel {

    /// Cells to be shown in this section.
    let cellViewModels: [CollectionCellViewModel]
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
    public var diffingKey: String?

    /// Initializes a collection view section view model.
    ///
    /// - Parameters:
    ///   - cellViewModels: the cells in this section.
    ///   - headerViewModel: the header view model (defaults to `nil`).
    ///   - footerViewModel: the footer view model (defaults to `nil`).
    ///   - diffingKey: the diffing key, required for automated diffing.
    public init(
        cellViewModels: [CollectionCellViewModel],
        headerViewModel: CollectionSupplementaryViewModel? = nil,
        footerViewModel: CollectionSupplementaryViewModel? = nil,
        diffingKey: String? = nil
        ) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.diffingKey = diffingKey
    }

    private struct BlankSupplementaryViewModel: CollectionSupplementaryViewModel {
        let height: CGFloat?
        let viewInfo: SupplementaryViewInfo? = nil

        func applyViewModelToView(_ view: UICollectionReusableView) { }
    }
}

// MARK: Initializers without header/footer view models

// Note: All initializers in this extension are undocumented, because we intend
// to remove them. We want to get rid of the legacy functionality that creates
// blank headers & footers instead of using spacing properties available via
// `UICollectionViewLayout`s.
extension CollectionSectionViewModel {

    /// :nodoc:
    public init(
        cellViewModels: [CollectionCellViewModel],
        headerHeight: CGFloat? = nil,
        footerViewModel: CollectionSupplementaryViewModel? = nil,
        diffingKey: String? = nil
        ) {
        self.init(
            cellViewModels: cellViewModels,
            headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
            footerViewModel: footerViewModel,
            diffingKey: diffingKey
        )
    }

    /// :nodoc:
    public init(
        cellViewModels: [CollectionCellViewModel],
        headerViewModel: CollectionSupplementaryViewModel? = nil,
        footerHeight: CGFloat? = nil,
        diffingKey: String? = nil
        ) {
        self.init(
            cellViewModels: cellViewModels,
            headerViewModel: headerViewModel,
            footerViewModel: BlankSupplementaryViewModel(height: footerHeight),
            diffingKey: diffingKey
        )
    }

    /// :nodoc:
    public init(
        cellViewModels: [CollectionCellViewModel],
        headerHeight: CGFloat? = nil,
        footerHeight: CGFloat? = nil,
        diffingKey: String? = nil
        ) {
        self.init(
            cellViewModels: cellViewModels,
            headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
            footerViewModel: BlankSupplementaryViewModel(height: footerHeight),
            diffingKey: diffingKey
        )
    }
}
