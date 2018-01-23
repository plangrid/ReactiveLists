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

public protocol CollectionViewCellViewModel {
    /// `CollectionViewDataSource` will automatically apply an `accessibilityIdentifier` to the cell based on this format
    var accessibilityFormat: CellAccessibilityFormat { get }

    var cellIdentifier: String { get }
    var shouldHighlight: Bool { get }
    var didSelectClosure: DidSelectClosure? { get }
    var didDeselectClosure: DidDeselectClosure? { get }

    @discardableResult
    func applyViewModelToCell(_ cell: UICollectionViewCell) -> UICollectionViewCell
}

public extension CollectionViewCellViewModel {
    var shouldHighlight: Bool { return true }

    var didSelectClosure: DidSelectClosure? { return nil }

    var didDeselectClosure: DidDeselectClosure? { return nil }
}

public protocol CollectionViewSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { get }
    var height: CGFloat? { get }

    @discardableResult
    func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView
}

public extension CollectionViewSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { return nil }
    var height: CGFloat? { return nil }

    func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView {
        return view
    }
}

public struct CollectionViewModel {
    public struct SectionModel {
        private struct BlankSupplementaryViewModel: CollectionViewSupplementaryViewModel {
            let height: CGFloat?
            let viewInfo: SupplementaryViewInfo? = nil

            func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView {
                return view
            }
        }

        let cellViewModels: [CollectionViewCellViewModel]?
        let headerViewModel: CollectionViewSupplementaryViewModel?
        let footerViewModel: CollectionViewSupplementaryViewModel?

        public init(
            cellViewModels: [CollectionViewCellViewModel]?,
            headerViewModel: CollectionViewSupplementaryViewModel? = nil,
            footerViewModel: CollectionViewSupplementaryViewModel? = nil
        ) {
            self.cellViewModels = cellViewModels
            self.headerViewModel = headerViewModel
            self.footerViewModel = footerViewModel
        }
    }

    public let sectionModels: [SectionModel]

    public init(sectionModels: [SectionModel]) {
        self.sectionModels = sectionModels
    }

    public subscript(section: Int) -> SectionModel? {
        guard self.sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    public subscript(indexPath: IndexPath) -> CollectionViewCellViewModel? {
        guard let section = self[indexPath.section],
            let cellViewModels = section.cellViewModels, cellViewModels.count > indexPath.item else { return nil }
        return cellViewModels[indexPath.item]
    }
}

// MARK: Initializers without header/footer view models

extension CollectionViewModel.SectionModel {

    public init(cellViewModels: [CollectionViewCellViewModel]?, headerHeight: CGFloat? = nil, footerViewModel: CollectionViewSupplementaryViewModel? = nil) {
        self.init(cellViewModels: cellViewModels,
                  headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
                  footerViewModel: footerViewModel)
    }

    public init(cellViewModels: [CollectionViewCellViewModel]?, headerViewModel: CollectionViewSupplementaryViewModel? = nil, footerHeight: CGFloat? = nil) {
        self.init(cellViewModels: cellViewModels,
                  headerViewModel: headerViewModel,
                  footerViewModel: BlankSupplementaryViewModel(height: footerHeight))
    }

    public init(cellViewModels: [CollectionViewCellViewModel]?, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil) {
        self.init(cellViewModels: cellViewModels,
                  headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
                  footerViewModel: BlankSupplementaryViewModel(height: footerHeight))
    }
}
