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

/// A Data Source that drives the Collection Views appereance and behavior in terms of view models for the individual cells.
@objc
public class CollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public let collectionView: UICollectionView

    public var collectionViewModel: CollectionViewModel? {
        willSet {
            assert(Thread.isMainThread, "Must set \(#function) on main thread")
        }
        didSet {
            self._collectionViewModelDidChange()
        }
    }

    private var _shouldDeselectUponSelection: Bool

    private var _collectionViewDiffer: CollectionViewDiffCalculator<DiffingKey, DiffingKey>?
    private let _automaticDiffingEnabled: Bool
    private var _didReceiveFirstNonNilValue = false

    private static let _hiddenSupplementaryViewIdentifier = "hidden-supplementary-view"

    public init(
        collectionViewModel: CollectionViewModel? = nil,
        collectionView: UICollectionView,
        shouldDeselectUponSelection: Bool = true,
        automaticDiffingEnabled: Bool = false
    ) {
        self.collectionViewModel = collectionViewModel
        self.collectionView = collectionView
        self._automaticDiffingEnabled = automaticDiffingEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        self._collectionViewModelDidChange()
    }

    private func _collectionViewModelDidChange() {
        self._registerSupplementaryViews()
        self._registerHiddenSupplementaryViews()

        guard let newModel = self.collectionViewModel else {
            self.refreshViews()
            return
        }

        if self._automaticDiffingEnabled {
            if !self._didReceiveFirstNonNilValue {
                // For the first non-nil value, we want to reload data, to avoid a weird
                // animation where we animate in the initial state
                self.collectionView.reloadData()
                self._didReceiveFirstNonNilValue = true

                // Now that we have this initial state, setup the differ with that initial state,
                // so that the diffing works properly from here on out
                self._collectionViewDiffer = CollectionViewDiffCalculator<DiffingKey, DiffingKey>(
                    collectionView: self.collectionView,
                    initialSectionedValues: newModel.diffingKeys
                )
            } else if self._didReceiveFirstNonNilValue {
                // If the current collection view model is empty, default to an empty set of diffing keys
                if let differ = self._collectionViewDiffer {
                    let diffingKeys = newModel.diffingKeys
                    differ.sectionedValues = diffingKeys
                    self.refreshViews()
                } else {
                    self.refreshViews()
                }
            }
        } else {
            self.refreshViews()
        }
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.collectionViewModel?.sectionModels.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewModel?[section]?.cellViewModels?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self._sizeForSupplementaryViewOfKind(.header, inSection: section, collectionViewLayout: collectionViewLayout)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self._sizeForSupplementaryViewOfKind(.footer, inSection: section, collectionViewLayout: collectionViewLayout)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        let elementKind = SupplementaryViewKind(collectionElementKindString: kind)
        let view: UICollectionReusableView

        if let elementKind = elementKind,
            let sectionModel = self.collectionViewModel?[section],
            let viewModel = elementKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
            let identifier = viewModel.viewInfo?.reuseIdentifier {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
        } else {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewDataSource._hiddenSupplementaryViewIdentifier, for: indexPath)
        }
        return view
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        if let cellViewModel = self.collectionViewModel?[indexPath] {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.cellIdentifier, for: indexPath)
            cellViewModel.applyViewModelToCell(cell)
            cell.accessibilityIdentifier = cellViewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        } else {
            cell = UICollectionViewCell()
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return self.collectionViewModel?[indexPath]?.shouldHighlight ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        self.collectionViewModel?[indexPath]?.didSelectClosure?()
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.collectionViewModel?[indexPath]?.didDeselectClosure?()
    }

    public func refreshViews() {
        guard let sections = self.collectionViewModel?.sectionModels, !sections.isEmpty else {
            return
        }

        let visibleIndexPathsForItems = self.collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPathsForItems {
            guard let model = self.collectionViewModel?[indexPath] else { continue }
            guard let cell = self.collectionView.cellForItem(at: indexPath) else { continue }
            model.applyViewModelToCell(cell)
            cell.accessibilityIdentifier = model.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        }

        let visibleIndexPathsForHeaders = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
        for indexPath in visibleIndexPathsForHeaders {
            guard let headerModel = self.collectionViewModel?[indexPath.section]?.headerViewModel else {
                continue
            }
            guard let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) else {
                continue
            }
            headerModel.applyViewModelToView(headerView)
            headerView.accessibilityIdentifier = headerModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(indexPath.section)
        }

        let visibleIndexPathsForFooters = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionFooter)
        for indexPath in visibleIndexPathsForFooters {
            guard let footerModel = self.collectionViewModel?[indexPath.section]?.footerViewModel else {
                continue
            }
            guard let footerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: indexPath) else {
                continue
            }
            footerModel.applyViewModelToView(footerView)
            footerView.accessibilityIdentifier = footerModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(indexPath.section)
        }
    }

    private func _registerSupplementaryViews() {
        self.collectionViewModel?.sectionModels.forEach {
            if let header = $0.headerViewModel?.viewInfo {
                switch header.registrationMethod {
                case let .nib(name, bundle):
                    collectionView.register(UINib(nibName: name, bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header.reuseIdentifier)
                case let .viewClass(viewClass):
                    collectionView.register(viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header.reuseIdentifier)
                }
            }
            if let footer = $0.footerViewModel?.viewInfo {
                switch footer.registrationMethod {
                case let .nib(name, bundle):
                    collectionView.register(UINib(nibName: name, bundle: bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footer.reuseIdentifier)
                case let .viewClass(viewClass):
                    collectionView.register(viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footer.reuseIdentifier)
                }
            }
        }
    }

    private func _registerHiddenSupplementaryViews() {
        // A blank header/footer view class must be registered because `viewForSupplementaryElementOfKind` returns
        // a non-optional view and yet the `collectionViewModel` may not specify some headers and footers
        [UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter].forEach {
            collectionView.register(UICollectionReusableView.self,
                                     forSupplementaryViewOfKind: $0,
                                     withReuseIdentifier: CollectionViewDataSource._hiddenSupplementaryViewIdentifier)
        }
    }

    private func _sizeForSupplementaryViewOfKind(_ elementKind: SupplementaryViewKind, inSection section: Int, collectionViewLayout: UICollectionViewLayout) -> CGSize {
        guard let sectionModel = self.collectionViewModel?[section] else {
            return CGSize.zero
        }

        let isHeader = elementKind == .header
        let supplementaryModel = isHeader ? sectionModel.headerViewModel : sectionModel.footerViewModel

        if let height = supplementaryModel?.height {
            return CGSize(width: 0, height: height)
        }

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, supplementaryModel?.viewInfo != nil else { return CGSize.zero }

        return isHeader ? flowLayout.headerReferenceSize : flowLayout.footerReferenceSize
    }

    private func _indexPathForSupplementaryViewInSection(_ section: Int) -> IndexPath {
        return IndexPath(row: 0, section: section)
    }
}
