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
import ReactiveSwift
import Result
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

    public var tableViewModel: MutableProperty<TableViewModel?> = MutableProperty(nil)

    var headersOnScreen: [IndexPath: UIView] = [:]
    var footersOnScreen: [IndexPath: UIView] = [:]
    var _tableViewModel: TableViewModel? { return self.tableViewModel.value }
    var _tableViewDiffer: TableViewDiffCalculator<DiffingKey, DiffingKey>?

    // internal for testing
    internal let _tableView: UITableView

    private let _shouldDeselectUponSelection: Bool
    private let _automaticDiffEnabled: Bool
    private let _fullyReloadCellsEnabled: Bool
    private var _didReceiveFirstNonNilValue = false

    public init(tableView: UITableView, automaticDiffEnabled: Bool = false, shouldDeselectUponSelection: Bool = true, fullyReloadCells: Bool = false) {
        self._automaticDiffEnabled = automaticDiffEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        self._fullyReloadCellsEnabled = fullyReloadCells
        self._tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        self.setUpTableViewModelChangeHandlers()
    }

    open func setUpTableViewModelChangeHandlers() {
        // Immediately register header footer views (don't bother switching to main thread)
        self.tableViewModel.producer.startWithValues { [weak self] _ in self?._registerHeaderFooterViews() }

        if self._automaticDiffEnabled {
            // Subscribe to updates to the table view model and inform the differ on each update
            // by providing the latest set of diffing keys.
            self.tableViewModel.producer.startWithValues { [weak self] newState in
                guard let `self` = self else { return }
                if let newState = newState, !self._didReceiveFirstNonNilValue {
                    // For the first non-nil value, we want to reload data, to avoid a weird
                    // animation where we animate in the initial state
                    self._tableView.reloadData()
                    self._didReceiveFirstNonNilValue = true

                    // Now that we have this initial state, setup the differ with that initial state,
                    // so that the diffing works properly from here on out
                    self._tableViewDiffer = TableViewDiffCalculator<DiffingKey, DiffingKey>(
                        tableView: self._tableView,
                        initialSectionedValues: newState.diffingKeys
                    )
                } else if self._didReceiveFirstNonNilValue {
                    // If the current table view model is empty, default to an empty set of diffing keys
                    if let differ = self._tableViewDiffer {
                        let diffingKeys = newState?.diffingKeys ?? SectionedValues()
                        let diff = Dwifft.diff(lhs: differ.sectionedValues, rhs: diffingKeys)
                        differ.sectionedValues = diffingKeys
                        let context: TableRefreshContext = !diff.isEmpty ? .rowsModified : .contentOnly
                        self.refreshViews(refreshContext: context)
                    } else {
                        self.refreshViews()
                    }
                }
            }
        } else {
            // Refresh views on the main thread whenever table view model changes
            self.tableViewModel.producer.onMainQueue().startWithValues { [weak self] _ in self?.refreshViews() }
        }
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self._tableViewModel?.sectionIndexTitles
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self._tableViewModel?.sectionModels?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = self._tableViewModel?[section], !sectionModel.collapsed else { return 0 }
        return sectionModel.cellViewModels?.count ?? 0
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self._tableViewModel?[section]?.headerViewModel?.height ?? CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self._tableViewModel?[section]?.footerViewModel?.height ?? CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = self._tableViewModel?[section]?.headerViewModel, header.viewInfo == nil else { return nil }
        return header.title
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let footer = self._tableViewModel?[section]?.footerViewModel, footer.viewInfo == nil else { return nil }
        return footer.title
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self._tableView(tableView, viewForHeaderInSection: section, viewKind: .header)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self._tableView(tableView, viewForHeaderInSection: section, viewKind: .footer)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if let cellViewModel = self._tableViewModel?[indexPath] {
            cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath)
            cellViewModel.applyViewModelToCell(cell)
            cell.accessibilityIdentifier = cellViewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        } else {
            cell = UITableViewCell()
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let indexPathKey = self._indexPathForHeaderFooterInSection(section)
        self.headersOnScreen.removeValue(forKey: indexPathKey)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let indexPathKey = self._indexPathForHeaderFooterInSection(section)
        self.footersOnScreen.removeValue(forKey: indexPathKey)
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self._tableViewModel?[indexPath]?.rowHeight ?? 44
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self._tableViewModel?[indexPath]?.willBeginEditing?()
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            self._tableViewModel?[indexPath]?.didEndEditing?()
        }
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return self._tableViewModel?[indexPath]?.editingStyle ?? .none
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if let cellViewModel = self._tableViewModel?[indexPath] as? TableViewCellModelEditActions {
            return cellViewModel.editActions(indexPath)
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self._tableViewModel?[indexPath]?.accessoryButtonTappedClosure?()
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return self._tableViewModel?[indexPath]?.shouldHighlight ?? true
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self._tableViewModel?[indexPath]?.commitEditingStyle?(editingStyle)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self._shouldDeselectUponSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self._tableViewModel?[indexPath]?.didSelectClosure?()
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self._tableViewModel?[indexPath]?.shouldIndentWhileEditing ?? true
    }

    public func refreshViews(_ locationFilter: ViewLocationFilter? = nil, refreshContext: TableRefreshContext = .unknown) {
        guard let sections = self._tableViewModel?.sectionModels, !sections.isEmpty else {
            return
        }

        let visibleIndexPaths = self._tableView.indexPathsForVisibleRows ?? []

        // Collect the index paths and views models to reload
        let indexPathsAndViewModelsToReload: [(IndexPath, TableViewCellViewModel)]
        indexPathsAndViewModelsToReload = visibleIndexPaths.flatMap { indexPath in
            if locationFilter?(.cell(indexPath)) ?? true {
                return self._tableViewModel?[indexPath].map { (indexPath, $0) }
            }
            return nil
        }

        if !indexPathsAndViewModelsToReload.isEmpty {
            // If there was a diff (or we don't know if there was one), then we can't do a
            // beginUpdates/endUpdates-type reload: either one already happened, or we'll
            // inadvertently cause a crash because we may not know that some rows are being
            // added/deleted
            for (indexPath, viewModel) in indexPathsAndViewModelsToReload {
                guard let cell = self._tableView.cellForRow(at: indexPath) else { continue }
                viewModel.applyViewModelToCell(cell)
                cell.accessibilityIdentifier = viewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
            }

            if refreshContext == .contentOnly {
                // If we're only updating content (i.e. no diff that would call begin/end updates)
                // call begin/end updates to ensure that row heights get a chance to update
                // Note: begin/end updates sometimes re-queries the data source, but not always,
                //       which is why we have to force refresh cells individually above
                self._tableView.beginUpdates()
                self._tableView.endUpdates()
            }
        }

        for (index, view) in self.headersOnScreen {
            guard locationFilter?(.header(index.section)) ?? true else { continue }
            guard let sectionModel = self._tableViewModel?[index.section],
                let viewModel = sectionModel.headerViewModel else { continue }
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(index.section)
        }

        for (index, view) in self.footersOnScreen {
            guard locationFilter?(.footer(index.section)) ?? true else { continue }
            guard let sectionModel = self._tableViewModel?[index.section],
                let viewModel = sectionModel.footerViewModel else { continue }
            viewModel.applyViewModelToView(view)
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(index.section)
        }
    }

    open func _tableView(_ tableView: UITableView, viewForHeaderInSection section: Int, viewKind: SupplementaryViewKind) -> UIView? {
        guard let sectionModel = self._tableViewModel?[section],
            let viewModel = viewKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
            let identifier = viewModel.viewInfo?.reuseIdentifier,
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) else { return nil }

        viewModel.applyViewModelToView(view)
        view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(section)

        let indexPathKey = self._indexPathForHeaderFooterInSection(section)
        switch viewKind {
        case .header:
            self.headersOnScreen[indexPathKey] = view
        case .footer:
            self.footersOnScreen[indexPathKey] = view
        }

        return view
    }

    func _registerHeaderFooterViews() {
        self._tableViewModel?.sectionModels?.forEach {
            if let header = $0.headerViewModel?.viewInfo {
                switch header.registrationMethod {
                case let .nib(name, bundle):
                    self._tableView.register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: header.reuseIdentifier)
                case let .viewClass(viewClass):
                    self._tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: header.reuseIdentifier)
                }
            }
            if let footer = $0.footerViewModel?.viewInfo {
                switch footer.registrationMethod {
                case let .nib(name, bundle):
                    self._tableView.register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: footer.reuseIdentifier)
                case let .viewClass(viewClass):
                    self._tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: footer.reuseIdentifier)
                }
            }
        }
    }

    func _indexPathForHeaderFooterInSection(_ section: Int) -> IndexPath {
        return IndexPath(row: 0, section: section)
    }
}
