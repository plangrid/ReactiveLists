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

/// View model for the individual cells of a `TableViewModel`.
public protocol TableCellViewModel: ReusableCellViewModelProtocol, DiffableViewModel {

    /// `TableViewDriver` will automatically apply an `accessibilityIdentifier` to the cell based on this format.
    var accessibilityFormat: CellAccessibilityFormat { get }

    /// The height of this cell.
    var rowHeight: CGFloat? { get }

    /// The editing style for this cell.
    var editingStyle: UITableViewCell.EditingStyle { get }

    /// Whether or not this cell should be highlighted.
    var shouldHighlight: Bool { get }

    /// Whether or not this cell should be indented while editing.
    var shouldIndentWhileEditing: Bool { get }

    /// Invoked when a cell will begin being edited.
    var willBeginEditing: WillBeginEditingClosure? { get }

    /// Invoked when cell editing has ended.
    var didEndEditing: DidEndEditingClosure? { get }

    /// Asks the cell to commit the insertion/deletion.
    var commitEditingStyle: CommitEditingStyleClosure? { get }

    /// Invoked when a cell has been selected.
    var didSelect: DidSelectClosure? { get }

    /// Invoked when a cell has been deselected.
    var didDeselect: DidDeselectClosure? { get }

    /// Invoked when an accessory button is tapped.
    var accessoryButtonTapped: AccessoryButtonTappedClosure? { get }

    /// Whether or not this cell should be selected.
    func shouldSelect(at: IndexPath) -> Bool

    /// Asks the cell model to update the `UITableViewCell` with the content
    /// in the cell model and return the updated cell.
    /// - Parameter cell: the cell which contents need to be updated.
    func applyViewModelToCell(_ cell: UITableViewCell)

    /// Invoke when  a cell will be displayed
    func willDisplay(cell: UITableViewCell)
}

/// Default implementations for `TableCellViewModel`.
extension TableCellViewModel {

    /// Default implementation, returns `nil`.
    /// - Note: If `nil`, the `TableViewDriver` will fallback to `TableViewModel.defaultRowHeight`.
    /// - See also: TableViewModel
    public var rowHeight: CGFloat? {
        return nil
    }

    /// Default implementation, returns `.none`.
    public var editingStyle: UITableViewCell.EditingStyle { return .none }

    /// Default implementation, returns `true`.
    public var shouldHighlight: Bool { return true }

    /// Default implementation, returns `false`.
    public var shouldIndentWhileEditing: Bool { return false }

    /// Default implementation, returns `nil`.
    public var willBeginEditing: WillBeginEditingClosure? { return nil }

    /// Default implementation, returns `nil`.
    public var didEndEditing: DidEndEditingClosure? { return nil }

    /// Default implementation, returns `nil`.
    public var commitEditingStyle: CommitEditingStyleClosure? { return nil }

    /// Default implementation, returns `nil`.
    public var didSelect: DidSelectClosure? { return nil }

    /// Default implementation, returns `nil`.
    public var didDeselect: DidDeselectClosure? { return nil }

    /// Default implementation, returns `nil`.
    public var accessoryButtonTapped: AccessoryButtonTappedClosure? { return nil }

    /// Default implementation, returns `true`.
    public func shouldSelect(at: IndexPath) -> Bool { return true }

    /// Default implementation
    public func willDisplay(cell: UITableViewCell) { }
}

/// Protocol that needs to be implemented by table view cell view models
/// that want to provide edit actions.
public protocol TableViewCellModelEditActions {

    /// The edit actions for this cell when swiping from the leading direction.
    var leadingSwipeActionConfiguration: UISwipeActionsConfiguration? { get }

    /// The edit actions for this cell when swiping from the trailing direction.
    var trailingSwipeActionConfiguration: UISwipeActionsConfiguration? { get }
}

/// Default implementation for `TableViewCellModelEditActions`.
extension TableViewCellModelEditActions {

    /// Default implementation, returns `nil`.
    public var leadingSwipeActionConfiguration: UISwipeActionsConfiguration? { return nil }

    /// Default implementation, returns `nil`.
    public var trailingSwipeActionConfiguration: UISwipeActionsConfiguration? { return nil }
}

/// The relative position of the section
public enum TableSectionPosition {

    /// The first section
    case first

    /// One of the middle sections
    case middle

    /// The last section
    case last
}

/// Protocol that needs to be implemented by custom header
/// footer view models.
public protocol TableSectionHeaderFooterViewModel: ReusableSupplementaryViewModelProtocol {

    /// The title of the header
    var title: String? { get }

    /// The height of the header
    /// - Note: this will become deprecated in a future release
    var height: CGFloat? { get }

    /// Asks the view model for its height, given the position
    /// of the section, to which it is tied
    func height(forPosition position: TableSectionPosition) -> CGFloat?

    /// Asks the view model to update the header/footer
    /// view with the content in the model.
    /// - Parameter view: the header/footer view
    func applyViewModelToView(_ view: UIView)
}

extension TableSectionHeaderFooterViewModel {

    /// Default implementation
    public func height(forPosition position: TableSectionPosition) -> CGFloat? {
        return self.height
    }

    /// Calculates the position given the section and number of sections
    /// and then calls `height(forPosition:)`
    func height(forSection section: Int, totalSections: Int) -> CGFloat? {
        let position: TableSectionPosition
        if section == 0 {
            position = .first
        } else if totalSections > 1 && section < totalSections - 1 {
            position = .middle
        } else {
            position = .last
        }
        return self.height(forPosition: position)
    }
}

/// View model for a table view section.
public struct TableSectionViewModel: DiffableViewModel {

    /// Cells to be shown in this section.
    @available(*, deprecated, message: "Use cellViewModelDataSource instead")
    public var cellViewModels: [TableCellViewModel] {
        return Array(self.cellViewModelDataSource)
    }

    /// Datasource for the cells to be shown in this section.
    public let cellViewModelDataSource: TableCellViewModelDataSource

    /// View model for the header of this section.
    public let headerViewModel: TableSectionHeaderFooterViewModel?

    /// View model for the footer of this section.
    public let footerViewModel: TableSectionHeaderFooterViewModel?

    /// The key used by the diffing algorithm to uniquely identify this section.
    /// If you are using automatic diffing on the `TableViewDriver` (which is enabled by default)
    /// you are required to provide a key that uniquely identifies this section.
    ///
    /// Typically you want to base this diffing key on data that is stored in the model.
    /// For example:
    ///
    ///      public var diffingKey = { group.identifier }
    public var diffingKey: String

    /// Returns `true` if this section has zero cell view models, `false` otherwise.
    public var isEmpty: Bool {
        return self.cellViewModelDataSource.isEmpty
    }

    /// Initializes a `TableSectionViewModel`.
    ///
    /// - Parameters:
    ///   - diffingKey: a `String` key unique to this section that is used to diff sections
    ///     automatically. Pass in `nil` if you are not using automatic diffing on this collection.
    ///   - cellViewModelDataSource: The datasource for the cell view models contained in this section.
    ///   - headerViewModel: A header view model for this section (defaults to `nil`).
    ///   - footerViewModel: A footer view model for this section (defaults to `nil`).
    public init(
        diffingKey: String?,
        cellViewModelDataSource: TableCellViewModelDataSource,
        headerViewModel: TableSectionHeaderFooterViewModel? = nil,
        footerViewModel: TableSectionHeaderFooterViewModel? = nil
    ) {
        self.cellViewModelDataSource = cellViewModelDataSource
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.diffingKey = diffingKey ?? UUID().uuidString
    }

    /// Initializes a `TableSectionViewModel`.
    ///
    /// - Parameters:
    ///   - diffingKey: a `String` key unique to this section that is used to diff sections
    ///     automatically. Pass in `nil` if you are not using automatic diffing on this collection.
    ///   - cellViewModels: The cell view models contained in this section.
    ///   - headerViewModel: A header view model for this section (defaults to `nil`).
    ///   - footerViewModel: A footer view model for this section (defaults to `nil`).
    public init(
        diffingKey: String?,
        cellViewModels: [TableCellViewModel],
        headerViewModel: TableSectionHeaderFooterViewModel? = nil,
        footerViewModel: TableSectionHeaderFooterViewModel? = nil
    ) {
        self.init(
            diffingKey: diffingKey,
            cellViewModelDataSource: TableCellViewModelDataSource(cellViewModels),
            headerViewModel: headerViewModel,
            footerViewModel: footerViewModel
        )
    }

    /// Initializes a `TableSectionViewModel`.
    ///
    /// - Parameters:
    ///   - headerTitle: The title for the header, or `nil`. Setting a title will cause a default header to be added to this section.
    ///   - headerHeight: The height of the default header, if one exists.
    ///   - cellViewModels: The cell view models contained in this section.
    ///   - footerTitle: The title for the footer, or `nil`. Setting a title will cause a default footeer to be added to this section.
    ///   - footerHeight: The height of the default footer, if one exists.
    ///   - diffingKey: A diffing key.
    public init(
        diffingKey: String?,
        headerTitle: String?,
        headerHeight: CGFloat?,
        cellViewModels: [TableCellViewModel],
        footerTitle: String? = nil,
        footerHeight: CGFloat? = 0
    ) {
        self.init(
            diffingKey: diffingKey,
            cellViewModels: cellViewModels,
            headerViewModel: PlainHeaderFooterViewModel(title: headerTitle, height: headerHeight),
            footerViewModel: PlainHeaderFooterViewModel(title: footerTitle, height: footerHeight)
        )
    }
}

/// `Collection` support for diffing
extension TableSectionViewModel: Collection {

    /// :nodoc:
    public subscript(position: Int) -> TableCellViewModel {
        return self.cellViewModelDataSource[position]
    }

    /// :nodoc:
    public func index(after i: Int) -> Int {
        return self.cellViewModelDataSource.index(after: i)
    }

    /// :nodoc:
    public var startIndex: Int {
        return self.cellViewModelDataSource.startIndex
    }

    /// :nodoc:
    public var endIndex: Int {
        return self.cellViewModelDataSource.endIndex
    }
}

/// The view model that describes a `UITableView`.
public struct TableViewModel {

    /// The default row height for this table view.  The default value is 44.
    public let defaultRowHeight: CGFloat

    /// The section index titles for this table view.
    public let sectionIndexTitles: [String]?

    /// The section view models for this table view.
    public let sectionModels: [TableSectionViewModel]

    /// Returns `true` if this table has all empty sections.
    public var isEmpty: Bool {
        return self.sectionModels.allSatisfy { $0.isEmpty }
    }

    /// Invoked when the tableview is scrolled
    public var didScrollClosure: DidScrollClosure?

    /// Initializes a table view model with one section and the cell models provided
    /// via the initializer.
    ///
    /// - Parameter cellViewModels: the cell models for the only section in this table.
    public init(cellViewModels: [TableCellViewModel], didScrollClosure: DidScrollClosure? = nil) {
        let section = TableSectionViewModel(
            diffingKey: "default_section",
            cellViewModels: cellViewModels
        )
        self.init(sectionModels: [section], didScrollClosure: didScrollClosure)
    }

    /// Initializes a table view model with the sections provided.
    /// Optionally accepts the `sectionIndexTitles` for this table view.
    ///
    /// - Parameters:
    ///   - sectionModels: the sections that need to be shown in this table view.
    ///   - sectionIndexTitles: the section index titles for this table view.
    ///   - didScrollClosure: the scroll closure for this table view.
    public init(sectionModels: [TableSectionViewModel], sectionIndexTitles: [String]? = nil, defaultRowHeight: CGFloat = 44.0, didScrollClosure: DidScrollClosure? = nil) {
        self.sectionModels = sectionModels
        self.sectionIndexTitles = sectionIndexTitles
        self.defaultRowHeight = defaultRowHeight
        self.didScrollClosure = didScrollClosure
    }

    /// Returns the section model at the specified index or `nil` if no such section exists.
    ///
    /// - Parameter section: the index for the section that is being retrieved
    public subscript(ifExists section: Int) -> TableSectionViewModel? {
        guard sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    /// Returns the cell view model at the specified index path or `nil` if no such cell exists.
    ///
    /// - Parameter indexPath: the index path for the cell that is being retrieved
    public subscript(ifExists indexPath: IndexPath) -> TableCellViewModel? {
        guard indexPath.count >= 2, // In rare cases, we've seen UIKit give us a bad IndexPath
            let section = self[ifExists: indexPath.section],
            section.cellViewModelDataSource.count > indexPath.row else { return nil }
        return section.cellViewModelDataSource[indexPath.row]
    }

    /// A view of `TableSectionViewModel` used for diffing
    func sectionModelsForDiffing(inVisibleIndexPaths visibleIndexPaths: [IndexPath]) -> [DiffableTableSectionViewModel] {
        let visibleIndicesBySection = [Int: AnySequence<Int>](
            uniqueKeysWithValues: visibleIndexPaths.indicesBySection()
        ).mapValues { Set($0) }
        return zip(sectionModels, sectionModels.indices).map { sectionModel, section in
            DiffableTableSectionViewModel(
                sectionModel: sectionModel,
                visibleIndices: visibleIndicesBySection[section, default: Set<Int>()]
            )
        }
    }
}

// MARK: Private

/// View model for a default header or footer view in a table view.
private struct PlainHeaderFooterViewModel: TableSectionHeaderFooterViewModel {
    let title: String?
    let height: CGFloat?
    let viewInfo: SupplementaryViewInfo? = nil

    func applyViewModelToView(_ view: UIView) {}
}
