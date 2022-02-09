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

/// A data source that drives the table views appereance and behavior based on an underlying
/// `TableViewModel`.
@objc
open class TableViewDriver: NSObject {

    /// Communicates information for refreshing the table view.
    public enum TableRefreshContext {
        /// A refresh was requested, but we don't know if rows/sections are being added/removed
        case unknown

        /// Only the content of cells is being refreshed. No rows/sections will be added/deleted.
        case contentOnly

        /// Rows/sections are being added/deleted
        case rowsModified
    }

    /// The table view to which the `TableViewModel` is rendered.
    public let tableView: UITableView

    private var _tableViewModel: TableViewModel?

    /// Describes the current UI state of the table view.
    ///
    /// When this property is set, the UI of the related `UITableView` will be updated.
    /// If not only the content of individual cells/sections has changed, but instead
    /// cells/sections were moved/inserted/deleted, the behavior of this setter depends on the
    /// value of the `automaticDiffingEnabled` property.
    ///
    /// If `automaticDiffingEnabled` is set to `true`, and cells/sections have been moved/inserted/deleted,
    /// updating this property will result in the UI of the table view being updated automatically.
    ///
    /// If `automaticDiffingEnabled` is set to `false`, and cells/sections have been moved/inserted/deleted,
    /// the caller must update the `UITableView` state manually, to bring it back in sync with
    /// the new model, e.g. by calling `reloadData()` on the table view.
    public var tableViewModel: TableViewModel? {
        set {
            assert(Thread.isMainThread, "Must set \(#function) on main thread")
            self._updateTableViewModel(from: self._tableViewModel, to: newValue)
        }
        get {
            return self._tableViewModel
        }
    }

    /// The animation for row insertions.
    public var insertionAnimation: UITableView.RowAnimation = .fade

    /// The animation for row deletions.
    public var deletionAnimation: UITableView.RowAnimation = .fade

    private let _shouldDeselectUponSelection: Bool

    private let _automaticDiffingEnabled: Bool

    /// Initializes a data source that drives a `UITableView` based on a `TableViewModel`.
    ///
    /// - Parameters:
    ///   - tableView: the table view to which this data source will render its view models.
    ///   - tableViewModel: the view model that describes the initial state of this table view.
    ///   - shouldDeselectUponSelection: indicates if selected cells should immediately be
    ///                                  deselected. Defaults to `true`.
    ///   - automaticDiffingEnabled: defines whether or not this data source updates the table
    ///                              view automatically when cells/sections are moved/inserted/deleted.
    ///                              Defaults to `true`.
    public init(
        tableView: UITableView,
        tableViewModel: TableViewModel? = nil,
        shouldDeselectUponSelection: Bool = true,
        automaticDiffingEnabled: Bool = true) {
        self._tableViewModel = tableViewModel
        self.tableView = tableView
        self._automaticDiffingEnabled = automaticDiffingEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        self._updateTableViewModel(from: nil, to: tableViewModel)
    }

    // MARK: Change and UI Update Handling

    /// Updates all currently visible cells and sections, such that they reflect the latest
    /// state decribed in their respective view models. Typically this method should not be
    /// called directly, as it is called automatically whenever the `tableViewModel` property
    /// is updated.
    public func refreshViews(refreshContext: TableRefreshContext = .unknown) {
        guard let sections = self.tableViewModel?.sectionModels, !sections.isEmpty else {
            return
        }

        let visibleIndexPaths = self.tableView.indexPathsForVisibleRows ?? []

        // Collect the index paths and views models to reload
        let indexPathsAndViewModelsToReload = visibleIndexPaths.compactMap { indexPath in
            return self.tableViewModel?[ifExists: indexPath].map { (indexPath, $0) }
        }

        if !indexPathsAndViewModelsToReload.isEmpty {
            // If there was a diff (or we don't know if there was one), then we can't do a
            // beginUpdates/endUpdates-type reload: either one already happened, or we'll
            // inadvertently cause a crash because we may not know that some rows are being
            // added/deleted
            for (indexPath, viewModel) in indexPathsAndViewModelsToReload {
                guard let cell = self.tableView.cellForRow(at: indexPath) else { continue }
                viewModel.applyViewModelToCell(cell)
                cell.accessibilityIdentifier = viewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
            }

            if refreshContext == .contentOnly {
                // If we're only updating content (i.e. no diff that would call begin/end updates)
                // call begin/end updates to ensure that row heights get a chance to update
                // Note: begin/end updates sometimes re-queries the data source, but not always,
                //       which is why we have to force refresh cells individually above
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }

        let visibleSections = Set<Int>(visibleIndexPaths.map { $0.section })
        for section in visibleSections {
            guard let sectionModel = self.tableViewModel?[ifExists: section] else { continue }

            if let headerView = self.tableView.headerView(forSection: section),
                let headerViewModel = sectionModel.headerViewModel {
                headerViewModel.applyViewModelToView(headerView)
                headerView.accessibilityIdentifier = headerViewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
            }

            if let footerView = self.tableView.footerView(forSection: section),
                let footerViewModel = sectionModel.footerViewModel {
                footerViewModel.applyViewModelToView(footerView)
                footerView.accessibilityIdentifier = footerViewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
            }
        }
    }

    // MARK: Private

    private func _updateTableViewModel(from oldModel: TableViewModel?, to newModel: TableViewModel?) {
        defer {
            // Ensure the new model gets updated
            self._tableViewModel = newModel
        }

        if let newModel = newModel {
            self.tableView.registerViews(for: newModel)
        }

        let previousStateNilOrEmpty = (oldModel == nil || oldModel!.isEmpty)
        let nextStateNilOrEmpty = (newModel == nil || newModel!.isEmpty)

        // 1. we're moving *from* a nil/empty state
        // or
        // 2. we're moving *to* a nil/empty state
        // in either case, simply reload and short-circuit, no need to diff
        if previousStateNilOrEmpty || nextStateNilOrEmpty {
            self._tableViewModel = newModel
            self.tableView.reloadData()
            return
        }

        guard let newModel = newModel else { return }

        if self._automaticDiffingEnabled {

            let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
            let old: [DiffableTableSectionViewModel] = oldModel?.sectionModelsForDiffing(inVisibleIndexPaths: visibleIndexPaths) ?? []
            let changeset = StagedChangeset(
                source: old,
                target: newModel.sectionModelsForDiffing(inVisibleIndexPaths: visibleIndexPaths)
            )
            if changeset.isEmpty {
                self._tableViewModel = newModel
            } else {
                self.tableView.reload(
                    using: changeset,
                    deleteSectionsAnimation: self.deletionAnimation,
                    insertSectionsAnimation: self.insertionAnimation,
                    reloadSectionsAnimation: self.insertionAnimation,
                    deleteRowsAnimation: self.deletionAnimation,
                    insertRowsAnimation: self.insertionAnimation,
                    reloadRowsAnimation: self.insertionAnimation
                ) {
                    self._tableViewModel = $0.makeTableViewModel(sectionIndexTitles: oldModel?.sectionIndexTitles)
                }
                self._tableViewModel = newModel
            }
            // always refresh visible cells, in case some
            // state changed that isn't captured by the diff
            self.refreshViews(refreshContext: .contentOnly)
        } else {
            self._tableViewModel = newModel
            // We need to call reloadData here to ensure UITableView is in-sync with the data source before we start
            // making calls to access visible cells. In the automatic diffing case, this is handled by calls to
            // beginUpdates() endUpdates()
            self.tableView.reloadData()
            self.refreshViews()
        }
    }

    private func _tableView(_ tableView: UITableView, viewForSection section: Int, viewKind: SupplementaryViewKind) -> UIView? {
        guard let sectionModel = self.tableViewModel?[ifExists: section],
            let viewModel = viewKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
            let identifier = viewModel.viewInfo?.registrationInfo.reuseIdentifier,
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) else {
                return nil
        }
        viewModel.applyViewModelToView(view)
        view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
        return view
    }
}

extension TableViewDriver: UITableViewDataSource {

    /// :nodoc:
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableViewModel = self.tableViewModel, let cellViewModel = tableViewModel[ifExists: indexPath] else {
            fatalError("Table View Model has an invalid configuration: \(String(describing: self.tableViewModel))")
        }
        return tableView.configuredCell(for: cellViewModel, at: indexPath)
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewModel = self.tableViewModel, let cellViewModel = tableViewModel[ifExists: indexPath] else {
            fatalError("Table View Model has an invalid configuration: \(String(describing: self.tableViewModel))")
        }

        cellViewModel.willDisplay(cell: cell)
    }

    /// :nodoc:
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewModel?.sectionModels.count ?? 0
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = self.tableViewModel?[ifExists: section] else { return 0 }
        return sectionModel.cellViewModelDataSource.count
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = self.tableViewModel?[ifExists: section]?.headerViewModel, header.viewInfo == nil else { return nil }
        return header.title
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let footer = self.tableViewModel?[ifExists: section]?.footerViewModel, footer.viewInfo == nil else { return nil }
        return footer.title
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tableViewModel?[ifExists: indexPath]?.commitEditingStyle?(editingStyle)
    }

    /// :nodoc:
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.tableViewModel?.sectionIndexTitles
    }
}

extension TableViewDriver: UITableViewDataSourcePrefetching {

    /// :nodoc:
    private func _enumerateCellDataSourcesForPrefetch(
        indexPaths: [IndexPath],
        enumerationBlock: (TableCellViewModelDataSource, AnySequence<Int>) -> Void
    ) {
        guard let sectionModels = self.tableViewModel?.sectionModels else { return }
        // if this is called during a batch update, sections can shift
        // around, which can lead to accessing a bad section
        let indexIsValid = sectionModels.indices.contains
        for (section, indices) in indexPaths.indicesBySection() where indexIsValid(section) {
            enumerationBlock(sectionModels[section].cellViewModelDataSource, indices)
        }
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        self._enumerateCellDataSourcesForPrefetch(
            indexPaths: indexPaths
        ) { datasource, indices in
            datasource.prefetchRowsAt(indices: indices)
        }
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        self._enumerateCellDataSourcesForPrefetch(
            indexPaths: indexPaths
        ) { datasource, indices in
            datasource.cancelPrefetchingRowsAt(indices: indices)
        }
    }
}

extension TableViewDriver: UITableViewDelegate {

    /// :nodoc:
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableViewModel = self.tableViewModel else { return 0 }
        return tableViewModel[ifExists: indexPath]?.rowHeight ?? tableViewModel.defaultRowHeight
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self._tableView(tableView, viewForSection: section, viewKind: .header)
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self._tableView(tableView, viewForSection: section, viewKind: .footer)
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableViewModel?[ifExists: section]?.headerViewModel?.height(forSection: section, totalSections: self.numberOfSections(in: tableView)) ?? CGFloat.leastNormalMagnitude
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableViewModel?[ifExists: section]?.footerViewModel?.height(forSection: section, totalSections: self.numberOfSections(in: tableView)) ?? CGFloat.leastNormalMagnitude
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let editActions = self.tableViewModel?[ifExists: indexPath] as? TableViewCellModelEditActions else { return nil }
        return editActions.leadingSwipeActionConfiguration
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let editActions = self.tableViewModel?[ifExists: indexPath] as? TableViewCellModelEditActions else { return nil }
        return editActions.trailingSwipeActionConfiguration
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.tableViewModel?[ifExists: indexPath]?.accessoryButtonTapped?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.tableViewModel?[ifExists: indexPath]?.didSelect?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let shouldSelect = self.tableViewModel?[ifExists: indexPath]?.shouldSelect(at: indexPath), !shouldSelect {
            return nil
        }

        return indexPath
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableViewModel?[ifExists: indexPath]?.didDeselect?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.tableViewModel?[ifExists: indexPath]?.willBeginEditing?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            self.tableViewModel?[ifExists: indexPath]?.didEndEditing?()
        }
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.tableViewModel?[ifExists: indexPath]?.editingStyle ?? .none
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewModel?[ifExists: indexPath]?.shouldIndentWhileEditing ?? true
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewModel?[ifExists: indexPath]?.shouldHighlight ?? true
    }
}
