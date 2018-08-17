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
    private enum NonDiffTableRefreshType {

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
            self._tableViewModelDidChange(from: oldValue)
        }
    }

    /// The animation for row insertions.
    public var insertionAnimation: UITableViewRowAnimation = .fade

    /// The animation for row deletions.
    public var deletionAnimation: UITableViewRowAnimation = .fade

    private let _shouldDeselectUponSelection: Bool

    private var _differ: TableViewDiffCalculator<DiffingKey, DiffingKey>?
    private let _automaticDiffingEnabled: Bool
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
        automaticDiffingEnabled: Bool = true) {
        self.tableViewModel = tableViewModel
        self.tableView = tableView
        self._automaticDiffingEnabled = automaticDiffingEnabled
        self._shouldDeselectUponSelection = shouldDeselectUponSelection
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        self._tableViewModelDidChange(from: nil)
    }

    // MARK: Change and UI Update Handling

    /// Updates all currently visible cells and sections, such that they reflect the latest
    /// state decribed in their respective view models.
    private func _refreshTable(_ type: NonDiffTableRefreshType) {
        switch type {
        case .rowsModified:
            self.tableView.reloadData()
        case .contentOnly:
            // We're only updating the content of the cells; we can use `beginUpdates/endUpdates`
            // to animate any height changes between content
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    // MARK: Private

    private func _tableViewModelDidChange(from: TableViewModel?) {
        if let newModel = self.tableViewModel {
            self.tableView.registerViews(for: newModel)
        }

        let previousStateNilOrEmpty = (from == nil || from!.isEmpty)
        let nextStateNilOrEmpty = (self.tableViewModel == nil || self.tableViewModel!.isEmpty)

        // 1. we're moving *from* a nil/empty state
        // or
        // 2. we're moving *to* a nil/empty state
        // in either case, simply reload and short-circuit, no need to diff
        if previousStateNilOrEmpty || nextStateNilOrEmpty {
            self.tableView.reloadData()

            if self._automaticDiffingEnabled
                && self.tableViewModel != nil
                && !self._didReceiveFirstNonNilNonEmptyValue {
                // Special case for the first non-nil value
                // Now that we have this initial state, setup the differ with that initial state,
                // so that the diffing works properly from here on out
                self._didReceiveFirstNonNilNonEmptyValue = true
                self._differ = TableViewDiffCalculator<DiffingKey, DiffingKey>(
                    tableView: self.tableView,
                    initialSectionedValues: self.tableViewModel!.diffingKeys)
            }
            return
        }

        guard let newModel = self.tableViewModel else { return }

        if self._automaticDiffingEnabled && self._didReceiveFirstNonNilNonEmptyValue, let differ = self._differ {
            differ.insertionAnimation = self.insertionAnimation
            differ.deletionAnimation = self.deletionAnimation
            let diffingKeys = newModel.diffingKeys
            let diff = Dwifft.diff(lhs: differ.sectionedValues, rhs: diffingKeys)
            differ.sectionedValues = diffingKeys
            if diff.isEmpty {
                // Dwift skips beginUpdates/endUpdates if there's no diff, so we need to ensure
                // content is updated
                self._refreshTable(.contentOnly)
            }
        } else {
            let refreshType = self._refreshTypeWithoutDiff(
                from: from,
                to: newModel
            )
            self._refreshTable(refreshType)
        }
    }

    private func _refreshTypeWithoutDiff(from: TableViewModel?, to: TableViewModel) -> NonDiffTableRefreshType {
        switch (from, to) {
        case let (from?, to):
            let rowCountsDiffer = (
                from.sectionModels.count != to.sectionModels.count ||
                    zip(from.sectionModels, to.sectionModels).contains { fromSection, toSection in
                        fromSection.cellViewModels.count != toSection.cellViewModels.count
                    }
            )
            return rowCountsDiffer ? .rowsModified : .contentOnly
        case (nil, _):
            return .rowsModified
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
        let cell = tableView.configuredCell(for: cellViewModel, at: indexPath)
        cell.accessibilityIdentifier = cellViewModel.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        return cell
    }

    /// :nodoc:
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewModel?.sectionModels.count ?? 0
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = self.tableViewModel?[section] else { return 0 }
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
