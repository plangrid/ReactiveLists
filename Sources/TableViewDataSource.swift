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

public typealias ViewLocationFilter = (ViewLocation) -> Bool

/// A Data Source that drives a dynamic table view's appereance and behavior in terms of view models for the individual cells.
@objc
open class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    /// Communicates information useful for refreshing the tableview
    ///
    /// - unknown: A refresh was requested, but we don't know if rows/sections are being added/removed
    /// - contentOnly: Only the content of cells is being refreshed. No rows/sections will be
    ///                added/deleted
    /// - rowsModified: Rows/sections are being added/deleted
    public enum TableRefreshContext {
        case unknown
        case contentOnly
        case rowsModified
    }

    public let tableView: UITableView

    public var tableViewModel: TableViewModel? {
        willSet {
            assert(Thread.isMainThread, "Must set \(#function) on main thread")
        }
        didSet {
            self._tableViewModelDidChange()
        }
    }

    private var _tableViewDiffer: TableViewDiffCalculator<DiffingKey, DiffingKey>?

    private let _shouldDeselectUponSelection: Bool
    private let _automaticDiffEnabled: Bool
    private let _fullyReloadCellsEnabled: Bool
    private var _didReceiveFirstNonNilValue = false

    public init(tableViewModel: TableViewModel? = nil,
                tableView: UITableView,
                automaticDiffEnabled: Bool = false,
                shouldDeselectUponSelection: Bool = true,
                fullyReloadCells: Bool = false) {
        self.tableViewModel = tableViewModel
        self.tableView = tableView
        self._automaticDiffEnabled = automaticDiffEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        self._fullyReloadCellsEnabled = fullyReloadCells
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        self._tableViewModelDidChange()
    }

    private func _tableViewModelDidChange() {
        self._registerHeaderFooterViews()

        guard let newModel = self.tableViewModel else {
            self.refreshViews()
            return
        }

        if self._automaticDiffEnabled {
            if !self._didReceiveFirstNonNilValue {
                // For the first non-nil value, we want to reload data, to avoid a weird
                // animation where we animate in the initial state
                self.tableView.reloadData()
                self._didReceiveFirstNonNilValue = true

                // Now that we have this initial state, setup the differ with that initial state,
                // so that the diffing works properly from here on out
                self._tableViewDiffer = TableViewDiffCalculator<DiffingKey, DiffingKey>(
                    tableView: self.tableView,
                    initialSectionedValues: newModel.diffingKeys
                )
            } else if self._didReceiveFirstNonNilValue {
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

    private func _registerHeaderFooterViews() {
        self.tableViewModel?.sectionModels.forEach {
            if let header = $0.headerViewModel?.viewInfo {
                switch header.registrationMethod {
                case let .nib(name, bundle):
                    self.tableView.register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: header.reuseIdentifier)
                case let .viewClass(viewClass):
                    self.tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: header.reuseIdentifier)
                }
            }
            if let footer = $0.footerViewModel?.viewInfo {
                switch footer.registrationMethod {
                case let .nib(name, bundle):
                    self.tableView.register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: footer.reuseIdentifier)
                case let .viewClass(viewClass):
                    self.tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: footer.reuseIdentifier)
                }
            }
        }
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.tableViewModel?.sectionIndexTitles
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewModel?.sectionModels.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = self.tableViewModel?[section], !sectionModel.collapsed else { return 0 }
        return sectionModel.cellViewModels?.count ?? 0
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableViewModel?[section]?.headerViewModel?.height ?? CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableViewModel?[section]?.footerViewModel?.height ?? CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = self.tableViewModel?[section]?.headerViewModel, header.viewInfo == nil else { return nil }
        return header.title
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let footer = self.tableViewModel?[section]?.footerViewModel, footer.viewInfo == nil else { return nil }
        return footer.title
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self._tableView(tableView, viewForSection: section, viewKind: .header)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self._tableView(tableView, viewForSection: section, viewKind: .footer)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if let cellViewModel = self.tableViewModel?[indexPath] {
            cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath)
            cellViewModel.applyViewModelToCell(cell)
            cell.accessibilityIdentifier = cellViewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        } else {
            cell = UITableViewCell()
        }

        return cell
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewModel?[indexPath]?.rowHeight ?? 44
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.tableViewModel?[indexPath]?.willBeginEditing?()
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            self.tableViewModel?[indexPath]?.didEndEditing?()
        }
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return self.tableViewModel?[indexPath]?.editingStyle ?? .none
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if let cellViewModel = self.tableViewModel?[indexPath] as? TableViewCellModelEditActions {
            return cellViewModel.editActions(indexPath)
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.tableViewModel?[indexPath]?.accessoryButtonTappedClosure?()
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewModel?[indexPath]?.shouldHighlight ?? true
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.tableViewModel?[indexPath]?.commitEditingStyle?(editingStyle)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.tableViewModel?[indexPath]?.didSelectClosure?()
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewModel?[indexPath]?.shouldIndentWhileEditing ?? true
    }

    public func refreshViews(_ locationFilter: ViewLocationFilter? = nil, refreshContext: TableRefreshContext = .unknown) {
        guard let sections = self.tableViewModel?.sectionModels, !sections.isEmpty else {
            return
        }

        let visibleIndexPaths = self.tableView.indexPathsForVisibleRows ?? []

        // Collect the index paths and views models to reload
        let indexPathsAndViewModelsToReload: [(IndexPath, TableViewCellViewModel)]
        indexPathsAndViewModelsToReload = visibleIndexPaths.flatMap { indexPath in
            if locationFilter?(.cell(indexPath)) ?? true {
                return self.tableViewModel?[indexPath].map { (indexPath, $0) }
            }
            return nil
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

    open func _tableView(_ tableView: UITableView, viewForSection section: Int, viewKind: SupplementaryViewKind) -> UIView? {
        guard let sectionModel = self.tableViewModel?[section],
            let viewModel = viewKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
            let identifier = viewModel.viewInfo?.reuseIdentifier,
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) else {
                return nil
        }
        viewModel.applyViewModelToView(view)
        view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)
        return view
    }
}
