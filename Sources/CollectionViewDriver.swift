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
import UIKit

/// A data source that drives the collection views appereance and behavior based on an underlying
/// `CollectionViewModel`.
@objc
public class CollectionViewDriver: NSObject {

    // MARK: Properties

    /// The collection view to which the `CollectionViewModel` is rendered.
    public let collectionView: UICollectionView

    private var _collectionViewModel: CollectionViewModel?

    /// Describes the current UI state of the collection view.
    ///
    /// When this property is set, the UI of the related `UICollectionView` will be updated.
    /// If not only the content of individual cells/sections has changed, but instead
    /// cells/sections were moved/inserted/deleted, the behavior of this setter depends on the
    /// value of the `automaticDiffingEnabled` property.
    ///
    /// If `automaticDiffingEnabled` is set to `true`, and cells/sections have been moved/inserted/deleted,
    /// updating this property will result in the UI of the collection view being updated automatically.
    ///
    /// If `automaticDiffingEnabled` is set to `false`, and cells/sections have been moved/inserted/deleted,
    /// the caller must update the `UICollectionView` state manually, to bring it back in sync with
    /// the new model, e.g. by calling `reloadData()` on the collection view.
    public var collectionViewModel: CollectionViewModel? {
        set {
            assert(Thread.isMainThread, "Must set \(#function) on main thread")
            self._updateCollectionViewModel(from: self._collectionViewModel, to: newValue)
        }
        get {
            return self._collectionViewModel
        }
    }

    private var _shouldDeselectUponSelection: Bool

    private let _automaticDiffingEnabled: Bool

    // MARK: Initialization

    /// Initializes a data source that drives a `UICollectionView` based on a `CollectionViewModel`.
    ///
    /// - Parameters:
    ///   - collectionView: the collection view to which this data source will render its view models.
    ///   - collectionViewModel: the view model that describes the initial state of this collection view.
    ///   - shouldDeselectUponSelection: indicates if selected cells should immediately be
    ///                                  deselected. Defaults to `true`.
    ///   - automaticDiffingEnabled: defines whether or not this data source updates the collection
    ///                              view automatically when cells/sections are moved/inserted/deleted.
    ///                              Defaults to `false`.
    public init(
        collectionView: UICollectionView,
        collectionViewModel: CollectionViewModel? = nil,
        shouldDeselectUponSelection: Bool = true,
        automaticDiffingEnabled: Bool = true) {
        self._collectionViewModel = collectionViewModel
        self.collectionView = collectionView
        self._automaticDiffingEnabled = automaticDiffingEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        self._updateCollectionViewModel(from: nil, to: collectionViewModel)
    }

    // MARK: Change and UI Update Handling

    /// Updates all currently visible cells and sections, such that they reflect the latest
    /// state decribed in their respective view models. Typically this method should not be
    /// called directly, as it is called automatically whenever the `collectionViewModel` property
    /// is updated.
    public func refreshViews() {
        guard let sections = self.collectionViewModel?.sectionModels, !sections.isEmpty else {
            return
        }

        let visibleIndexPathsForItems = self.collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPathsForItems {
            guard let model = self.collectionViewModel?[ifExists: indexPath] else { continue }
            guard let cell = self.collectionView.cellForItem(at: indexPath) else { continue }
            model.applyViewModelToCell(cell)
            cell.accessibilityIdentifier = model.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        }

        let visibleIndexPathsForHeaders = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
        for indexPath in visibleIndexPathsForHeaders {
            guard let headerModel = self.collectionViewModel?[ifExists: indexPath.section]?.headerViewModel else {
                continue
            }
            guard let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) else {
                continue
            }
            headerModel.applyViewModelToView(headerView)
            headerView.accessibilityIdentifier = headerModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(indexPath.section)
        }

        let visibleIndexPathsForFooters = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter)
        for indexPath in visibleIndexPathsForFooters {
            guard let footerModel = self.collectionViewModel?[ifExists: indexPath.section]?.footerViewModel else {
                continue
            }
            guard let footerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: indexPath) else {
                continue
            }
            footerModel.applyViewModelToView(footerView)
            footerView.accessibilityIdentifier = footerModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(indexPath.section)
        }
    }

    // MARK: Private

    private func _updateCollectionViewModel(from oldModel: CollectionViewModel?, to newModel: CollectionViewModel?) {
        defer {
            self._collectionViewModel = newModel
        }

        if let newModel = newModel {
            self.collectionView.registerViews(for: newModel)
        }

        let previousStateNilOrEmpty = (oldModel == nil || oldModel!.isEmpty)
        let nextStateNilOrEmpty = (newModel == nil || newModel!.isEmpty)

        // 1. we're moving *from* a nil/empty state
        // or
        // 2. we're moving *to* a nil/empty state
        // in either case, simply reload and short-circuit, no need to diff
        if previousStateNilOrEmpty || nextStateNilOrEmpty {
            self._collectionViewModel = newModel
            self.collectionView.reloadData()
            return
        }

        guard let newModel = newModel else { return }

        if self._automaticDiffingEnabled {

            let old: [CollectionSectionViewModel] = oldModel?.sectionModels ?? []
            let changeset = StagedChangeset(source: old, target: newModel.sectionModels)
            if changeset.isEmpty {
                self._collectionViewModel = newModel
            } else {
                self.collectionView.reload(using: changeset) {
                    self._collectionViewModel = CollectionViewModel(sectionModels: $0)
                }
            }
            self.refreshViews()
        } else {
            self.refreshViews()
        }
    }

    private func _sizeForSupplementaryViewOfKind(_ elementKind: SupplementaryViewKind, inSection section: Int, collectionViewLayout: UICollectionViewLayout) -> CGSize {
        guard let sectionModel = self.collectionViewModel?[ifExists: section] else { return CGSize.zero }
        let isHeader = elementKind == .header
        let supplementaryModel = isHeader ? sectionModel.headerViewModel : sectionModel.footerViewModel
        if let height = supplementaryModel?.height {
            return CGSize(width: 0, height: height)
        }

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, supplementaryModel?.viewInfo != nil else {
            return CGSize.zero
        }
        return isHeader ? flowLayout.headerReferenceSize : flowLayout.footerReferenceSize
    }
}

extension CollectionViewDriver: UICollectionViewDataSource {

    /// :nodoc:
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.collectionViewModel?.sectionModels.count ?? 0
    }

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionModel = self.collectionViewModel?[ifExists: section] else { return 0 }
        return sectionModel.cellViewModels.count
    }

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionViewModel = self.collectionViewModel, let cellViewModel = collectionViewModel[ifExists: indexPath] else {
            fatalError("Collection View Model has an invalid configuration: \(String(describing: self.collectionViewModel))")
        }
        return collectionView.configuredCell(for: cellViewModel, at: indexPath)
    }

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        let elementKind = SupplementaryViewKind(collectionElementKindString: kind)
        let view: UICollectionReusableView

        if let elementKind = elementKind,
            let sectionModel = self.collectionViewModel?[ifExists: section],
            let viewModel = elementKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
            let identifier = viewModel.viewInfo?.registrationInfo.reuseIdentifier {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
        } else {
            view = UICollectionReusableView()
        }
        return view
    }
}

extension CollectionViewDriver: UICollectionViewDelegate {

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        self.collectionViewModel?[ifExists: indexPath]?.didSelect?()
    }

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.collectionViewModel?[ifExists: indexPath]?.didDeselect?()
    }

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return self.collectionViewModel?[ifExists: indexPath]?.shouldHighlight ?? true
    }
}

extension CollectionViewDriver: UICollectionViewDelegateFlowLayout {

    // MARK: Supplementary view sizing

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self._sizeForSupplementaryViewOfKind(.header, inSection: section, collectionViewLayout: collectionViewLayout)
    }

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self._sizeForSupplementaryViewOfKind(.footer, inSection: section, collectionViewLayout: collectionViewLayout)
    }

    // MARK: Cell view sizing

    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            assertionFailure("A non-flow layout should not hit this delegate method")
            return .zero
        }

        if let item = self.collectionViewModel?[ifExists: indexPath] as? FlowLayoutCollectionCellViewModel {
            return item.itemSize(in: collectionView, layout: flowLayout, indexPath: indexPath)
        }

        return flowLayout.itemSize
    }
}
