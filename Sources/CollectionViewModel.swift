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

public protocol CollectionViewCellViewModel {
    /// `CollectionViewDataSource` will automatically apply an `accessibilityIdentifier` to the cell based on this format
    var accessibilityFormat: CellAccessibilityFormat { get }

    var cellIdentifier: String { get }
    var shouldHighlight: Bool { get }
    var didSelect: DidSelectClosure? { get }
    var didDeselect: DidDeselectClosure? { get }

    func applyViewModelToCell(_ cell: UICollectionViewCell)
}

/// Default implementations for `CollectionViewCellViewModel`.
public extension CollectionViewCellViewModel {
    var shouldHighlight: Bool { return true }
    var didSelect: DidSelectClosure? { return nil }
    var didDeselect: DidDeselectClosure? { return nil }
}

/// View model for supplementary views in collection views.
public protocol CollectionViewSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { get }
    var height: CGFloat? { get }

    func applyViewModelToView(_ view: UICollectionReusableView)
}

/// Default implementations for `CollectionViewSupplementaryViewModel`.
public extension CollectionViewSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { return nil }
    var height: CGFloat? { return nil }

    func applyViewModelToView(_ view: UICollectionReusableView) {}
}

public struct CollectionViewModel {

    public let sectionModels: [CollectionViewSectionViewModel]

    public init(sectionModels: [CollectionViewSectionViewModel]) {
        self.sectionModels = sectionModels
    }

    public subscript(section: Int) -> CollectionViewSectionViewModel? {
        guard self.sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    public subscript(indexPath: IndexPath) -> CollectionViewCellViewModel? {
        guard let section = self[indexPath.section],
            let cellViewModels = section.cellViewModels, cellViewModels.count > indexPath.item else { return nil }
        return cellViewModels[indexPath.item]
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
                let cellDiffingKeys: [DiffingKey] = section.cellViewModels?.map { cell in
                    guard let cell = cell as? DiffableViewModel else {
                        fatalError("When diffing is enabled you need to provide cells which are DiffableViews.")
                    }
                    return "\(type(of: cell))_\(cell.diffingKey)"
                    } ?? []

                return (sectionDiffingKey, cellDiffingKeys)
            }
        )
    }
}

public struct CollectionViewSectionViewModel {
    private struct BlankSupplementaryViewModel: CollectionViewSupplementaryViewModel {
        let height: CGFloat?
        let viewInfo: SupplementaryViewInfo? = nil

        func applyViewModelToView(_ view: UICollectionReusableView) { }
    }

    let cellViewModels: [CollectionViewCellViewModel]?
    let headerViewModel: CollectionViewSupplementaryViewModel?
    let footerViewModel: CollectionViewSupplementaryViewModel?
    public var diffingKey: String?

    public init(
        cellViewModels: [CollectionViewCellViewModel]?,
        headerViewModel: CollectionViewSupplementaryViewModel? = nil,
        footerViewModel: CollectionViewSupplementaryViewModel? = nil,
        diffingKey: String? = nil
        ) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.diffingKey = diffingKey
    }
}

// MARK: Initializers without header/footer view models

extension CollectionViewSectionViewModel {

    public init(
        cellViewModels: [CollectionViewCellViewModel]?,
        headerHeight: CGFloat? = nil,
        footerViewModel: CollectionViewSupplementaryViewModel? = nil,
        diffingKey: String? = nil
    ) {
        self.init(
            cellViewModels: cellViewModels,
            headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
            footerViewModel: footerViewModel,
            diffingKey: diffingKey
        )
    }

    public init(
        cellViewModels: [CollectionViewCellViewModel]?,
        headerViewModel: CollectionViewSupplementaryViewModel? = nil,
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

    public init(
        cellViewModels: [CollectionViewCellViewModel]?,
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
