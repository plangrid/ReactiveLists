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
        willSet {
            assert(Thread.isMainThread, "Must set \(#function) on main thread")
        }
        didSet {
            self._tableViewModelDidChange()
        }
    }

    /// If this property is set to `true`, updating the `tableViewModel` will always
    /// automatically lead to updating the UI state of the `UITableView`, even if cells/sections
    /// were moved/inserted/deleted.
    ///
    /// For details, see the documentation for `TableViewDriver.tableViewModel`.
    private let _automaticDiffingEnabled: Bool

    private let _shouldDeselectUponSelection: Bool
    private var _tableViewDiffer: TableViewDiffCalculator<DiffingKey, DiffingKey>?
    private var _didReceiveFirstNonNilNonEmptyValue = false

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
        automaticDiffingEnabled: Bool = true
    ) {
        self.tableViewModel = tableViewModel
        self.tableView = tableView
        self._automaticDiffingEnabled = automaticDiffingEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        self._tableViewModelDidChange()
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
            return self.tableViewModel?[indexPath].map { (indexPath, $0) }
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
            guard let sectionModel = self.tableViewModel?[section] else { continue }

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

    private func _tableViewModelDidChange() {
        guard let newModel = self.tableViewModel, !newModel.isEmpty else {
            self.tableView.reloadData()
            return
        }

        self.tableView.registerViews(for: newModel)

        if self._automaticDiffingEnabled {
            if !self._didReceiveFirstNonNilNonEmptyValue {
                // For the first non-nil value, we want to reload data, to avoid a weird
                // animation where we animate in the initial state
                self.tableView.reloadData()
                self._didReceiveFirstNonNilNonEmptyValue = true

                // Now that we have this initial state, setup the differ with that initial state,
                // so that the diffing works properly from here on out
                self._tableViewDiffer = TableViewDiffCalculator<DiffingKey, DiffingKey>(
                    tableView: self.tableView,
                    initialSectionedValues: newModel.diffingKeys
                )
                self._tableViewDiffer?.insertionAnimation = .fade
                self._tableViewDiffer?.deletionAnimation = .fade
            } else if self._didReceiveFirstNonNilNonEmptyValue {
                // If the current table view model is empty, default to an empty set of diffing keys
                if let differ = self._tableViewDiffer {
                    let diffingKeys = newModel.diffingKeys
                    let diff = Dwifft.diff(lhs: differ.sectionedValues, rhs: diffingKeys)
                    differ.sectionedValues = diffingKeys
                    let context: TableRefreshContext = !diff.isEmpty ? .rowsModified : .contentOnly
                    self.refreshViews(refreshContext: context)
                } else {
                    self.refreshViews()
                }
            }
        } else {
            self.refreshViews()
        }
    }

    private func _tableView(_ tableView: UITableView, viewForSection section: Int, viewKind: SupplementaryViewKind) -> UIView? {
        guard let sectionModel = self.tableViewModel?[section],
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
        guard let tableViewModel = self.tableViewModel, let cellViewModel = tableViewModel[indexPath] else {
            fatalError("Table View Model has an invalid configuration: \(String(describing: self.tableViewModel))")
        }
        return tableView.configuredCell(for: cellViewModel, at: indexPath)
    }

    /// :nodoc:
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewModel?.sectionModels.count ?? 0
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = self.tableViewModel?[section], !sectionModel.collapsed else { return 0 }
        return sectionModel.cellViewModels.count
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = self.tableViewModel?[section]?.headerViewModel, header.viewInfo == nil else { return nil }
        return header.title
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let footer = self.tableViewModel?[section]?.footerViewModel, footer.viewInfo == nil else { return nil }
        return footer.title
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.tableViewModel?[indexPath]?.commitEditingStyle?(editingStyle)
    }

    /// :nodoc:
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.tableViewModel?.sectionIndexTitles
    }
}

extension TableViewDriver: UITableViewDelegate {

    /// :nodoc:
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewModel?[indexPath]?.rowHeight ?? 44
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
        return self.tableViewModel?[section]?.headerViewModel?.height ?? CGFloat.leastNormalMagnitude
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableViewModel?[section]?.footerViewModel?.height ?? CGFloat.leastNormalMagnitude
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let cellViewModel = self.tableViewModel?[indexPath] as? TableViewCellModelEditActions {
            return cellViewModel.editActions
        }
        return nil
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.tableViewModel?[indexPath]?.accessoryButtonTapped?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.tableViewModel?[indexPath]?.didSelect?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.tableViewModel?[indexPath]?.willBeginEditing?()
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            self.tableViewModel?[indexPath]?.didEndEditing?()
        }
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return self.tableViewModel?[indexPath]?.editingStyle ?? .none
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewModel?[indexPath]?.shouldIndentWhileEditing ?? true
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewModel?[indexPath]?.shouldHighlight ?? true
    }
}
