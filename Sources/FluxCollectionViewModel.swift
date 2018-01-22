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

public protocol FluxCollectionViewCellViewModel {
    /// `FluxCollectionViewDataSource` will automatically apply an `accessibilityIdentifier` to the cell based on this format
    var accessibilityFormat: CellAccessibilityFormat { get }

    var cellIdentifier: String { get }
    var shouldHighlight: Bool { get }
    var didSelectClosure: DidSelectClosure? { get }
    var didDeselectClosure: DidDeselectClosure? { get }

    @discardableResult
    func applyViewModelToCell(_ cell: UICollectionViewCell) -> UICollectionViewCell
}

public extension FluxCollectionViewCellViewModel {
    var shouldHighlight: Bool { return true }

    var didSelectClosure: DidSelectClosure? { return nil }

    var didDeselectClosure: DidDeselectClosure? { return nil }
}

public protocol FluxCollectionViewSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { get }
    var height: CGFloat? { get }

    @discardableResult
    func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView
}

public extension FluxCollectionViewSupplementaryViewModel {
    var viewInfo: SupplementaryViewInfo? { return nil }
    var height: CGFloat? { return nil }

    func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView {
        return view
    }
}

public struct FluxCollectionViewModel {
    public struct SectionModel {
        private struct BlankSupplementaryViewModel: FluxCollectionViewSupplementaryViewModel {
            let height: CGFloat?
            let viewInfo: SupplementaryViewInfo? = nil

            func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView {
                return view
            }
        }

        let cellViewModels: [FluxCollectionViewCellViewModel]?
        let headerViewModel: FluxCollectionViewSupplementaryViewModel?
        let footerViewModel: FluxCollectionViewSupplementaryViewModel?

        public init(cellViewModels: [FluxCollectionViewCellViewModel]?, headerViewModel: FluxCollectionViewSupplementaryViewModel? = nil,
                    footerViewModel: FluxCollectionViewSupplementaryViewModel? = nil) {
            self.cellViewModels = cellViewModels
            self.headerViewModel = headerViewModel
            self.footerViewModel = footerViewModel
        }
    }

    public let sectionModels: [SectionModel]?

    public init(sectionModels: [SectionModel]?) {
        self.sectionModels = sectionModels
    }

    public subscript(section: Int) -> SectionModel? {
        guard let sectionModels = self.sectionModels, sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    public subscript(indexPath: IndexPath) -> FluxCollectionViewCellViewModel? {
        guard let section = self[indexPath.section],
            let cellViewModels = section.cellViewModels, cellViewModels.count > indexPath.item else { return nil }
        return cellViewModels[indexPath.item]
    }
}

// MARK: Initializers without header/footer view models

extension FluxCollectionViewModel.SectionModel {

    public init(cellViewModels: [FluxCollectionViewCellViewModel]?, headerHeight: CGFloat? = nil, footerViewModel: FluxCollectionViewSupplementaryViewModel? = nil) {
        self.init(cellViewModels: cellViewModels,
                  headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
                  footerViewModel: footerViewModel)
    }

    public init(cellViewModels: [FluxCollectionViewCellViewModel]?, headerViewModel: FluxCollectionViewSupplementaryViewModel? = nil, footerHeight: CGFloat? = nil) {
        self.init(cellViewModels: cellViewModels,
                  headerViewModel: headerViewModel,
                  footerViewModel: BlankSupplementaryViewModel(height: footerHeight))
    }

    public init(cellViewModels: [FluxCollectionViewCellViewModel]?, headerHeight: CGFloat? = nil, footerHeight: CGFloat? = nil) {
        self.init(cellViewModels: cellViewModels,
                  headerViewModel: BlankSupplementaryViewModel(height: headerHeight),
                  footerViewModel: BlankSupplementaryViewModel(height: footerHeight))
    }
}
