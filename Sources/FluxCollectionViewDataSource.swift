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

import ReactiveSwift
import UIKit

/// A Data Source that drives the Collection Views appereance and behavior in terms of view models for the individual cells.
@objc
public class FluxCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private static let _hiddenSupplementaryViewIdentifier = "hidden-supplementary-view"

    public weak var collectionView: UICollectionView? {
        didSet {
            self.collectionView?.delegate = self
            self.collectionView?.dataSource = self
            self._registerSupplementaryViews()
            self._registerHiddenSupplementaryViews()
        }
    }

    public var collectionViewModel: MutableProperty<FluxCollectionViewModel?> = MutableProperty(nil)
    var _cellsOnScreen: [IndexPath: UICollectionViewCell] = [:]
    var _headersOnScreen: [IndexPath: UICollectionReusableView] = [:]
    var _footersOnScreen: [IndexPath: UICollectionReusableView] = [:]
    private var _collectionViewModel: FluxCollectionViewModel? { return self.collectionViewModel.value }
    private var _shouldDeselectUponSelection: Bool

    public init(shouldDeselectUponSelection: Bool = true) {
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        super.init()

        self._registerSupplementaryViews()
        self.collectionViewModel.producer.onMainQueue().startWithValues { [weak self] _ in
            self?.refreshViews()
        }
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self._collectionViewModel?.sectionModels?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._collectionViewModel?[section]?.cellViewModels?.count ?? 0
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
            let sectionModel = self._collectionViewModel?[section],
            let viewModel = elementKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
            let identifier = viewModel.viewInfo?.reuseIdentifier {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
        } else {
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: FluxCollectionViewDataSource._hiddenSupplementaryViewIdentifier, for: indexPath)
        }

        let indexPathKey = self._indexPathForSupplementaryViewInSection(section)
        if let elementKind = elementKind {
            switch elementKind {
            case .header:
                self._headersOnScreen[indexPathKey] = view
            case .footer:
                self._footersOnScreen[indexPathKey] = view
            }
        }

        return view
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        if let cellViewModel = self._collectionViewModel?[indexPath] {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.cellIdentifier, for: indexPath)
            cellViewModel.applyViewModelToCell(cell)
            cell.accessibilityIdentifier = cellViewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        } else {
            cell = UICollectionViewCell()
        }

        self._cellsOnScreen[indexPath] = cell
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self._cellsOnScreen.removeValue(forKey: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let viewKind = SupplementaryViewKind(collectionElementKindString: elementKind) else { return }
        let indexPathKey = self._indexPathForSupplementaryViewInSection(indexPath.section)

        switch viewKind {
        case .header:
            self._headersOnScreen.removeValue(forKey: indexPathKey)
        case .footer:
            self._footersOnScreen.removeValue(forKey: indexPathKey)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return self._collectionViewModel?[indexPath]?.shouldHighlight ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        self._collectionViewModel?[indexPath]?.didSelectClosure?()
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self._collectionViewModel?[indexPath]?.didDeselectClosure?()
    }

    public func refreshViews() {
        guard let sections = self._collectionViewModel?.sectionModels, !sections.isEmpty else {
            return
        }

        for (index, cell) in self._cellsOnScreen {
            if let viewModel = self._collectionViewModel?[index] {
                viewModel.applyViewModelToCell(cell)
                cell.accessibilityIdentifier = viewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(index)
            }
        }

        for (index, view) in self._headersOnScreen {
            guard let sectionModel = self._collectionViewModel?[index.section],
                let viewModel = sectionModel.headerViewModel else { continue }
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(index.section)
        }

        for (index, view) in self._footersOnScreen {
            guard let sectionModel = self._collectionViewModel?[index.section],
                let viewModel = sectionModel.footerViewModel else { continue }
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(index.section)
        }
    }

    private func _registerSupplementaryViews() {
        guard let collectionView = self.collectionView else { return }
        self._collectionViewModel?.sectionModels?.forEach {
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
            collectionView?.register(UICollectionReusableView.self,
                                     forSupplementaryViewOfKind: $0,
                                     withReuseIdentifier: FluxCollectionViewDataSource._hiddenSupplementaryViewIdentifier)
        }
    }

    private func _sizeForSupplementaryViewOfKind(_ elementKind: SupplementaryViewKind, inSection section: Int, collectionViewLayout: UICollectionViewLayout) -> CGSize {
        guard let sectionModel = self._collectionViewModel?[section] else { return CGSize.zero }

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
