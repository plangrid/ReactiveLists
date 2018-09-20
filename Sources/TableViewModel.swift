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
    var rowHeight: CGFloat { get }

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

    /// Invoked when an accessory button is tapped.
    var accessoryButtonTapped: AccessoryButtonTappedClosure? { get }

    /// Asks the cell model to update the `UITableViewCell` with the content
    /// in the cell model and return the updated cell.
    /// - Parameter cell: the cell which contents need to be updated.
    func applyViewModelToCell(_ cell: UITableViewCell)
}

/// Default implementations for `TableCellViewModel`.
public extension TableCellViewModel {

    /// Default implementation, returns `44.0`.
    var rowHeight: CGFloat {
        return 44.0
    }

    /// Default implementation, returns `.none`.
    var editingStyle: UITableViewCell.EditingStyle { return .none }

    /// Default implementation, returns `true`.
    var shouldHighlight: Bool { return true }

    /// Default implementation, returns `false`.
    var shouldIndentWhileEditing: Bool { return false }

    /// Default implementation, returns `nil`.
    var willBeginEditing: WillBeginEditingClosure? { return nil }

    /// Default implementation, returns `nil`.
    var didEndEditing: DidEndEditingClosure? { return nil }

    /// Default implementation, returns `nil`.
    var commitEditingStyle: CommitEditingStyleClosure? { return nil }

    /// Default implementation, returns `nil`.
    var didSelect: DidSelectClosure? { return nil }

    /// Default implementation, returns `nil`.
    var accessoryButtonTapped: AccessoryButtonTappedClosure? { return nil }
}

/// Protocol that needs to be implemented by table view cell view models
/// that want to provide edit actions.
public protocol TableViewCellModelEditActions {

    /// The row edit actions for the cell.
    var editActions: [UITableViewRowAction] { get }
}

/// Protocol that needs to be implemented by custom header
/// footer view models.
public protocol TableSectionHeaderFooterViewModel: ReusableSupplementaryViewModelProtocol {

    /// The title of the header
    var title: String? { get }

    /// The height of the header
    var height: CGFloat? { get }

    /// Asks the view model to update the header/footer
    /// view with the content in the model.
    /// - Parameter view: the header/footer view
    func applyViewModelToView(_ view: UIView)
}

/// View model for a table view section.
public struct TableSectionViewModel: DiffableViewModel {

    /// Cells to be shown in this section.
    public let cellViewModels: [TableCellViewModel]

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
        return self.cellViewModels.isEmpty
    }

    /// Initializes a `TableSectionViewModel`.
    ///
    /// - Parameters:
    ///   - cellViewModels: The cell view models contained in this section.
    ///   - headerViewModel: A header view model for this section (defaults to `nil`).
    ///   - footerViewModel: A footer view model for this section (defaults to `nil`).
    ///   - diffingKey: A diffing key.
    public init(
        cellViewModels: [TableCellViewModel],
        headerViewModel: TableSectionHeaderFooterViewModel? = nil,
        footerViewModel: TableSectionHeaderFooterViewModel? = nil,
        diffingKey: String = UUID().uuidString) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.diffingKey = diffingKey
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
        headerTitle: String?,
        headerHeight: CGFloat?,
        cellViewModels: [TableCellViewModel],
        footerTitle: String? = nil,
        footerHeight: CGFloat? = 0,
        diffingKey: String = UUID().uuidString) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = PlainHeaderFooterViewModel(title: headerTitle, height: headerHeight)
        self.footerViewModel = PlainHeaderFooterViewModel(title: footerTitle, height: footerHeight)
        self.diffingKey = diffingKey
    }
}

/// `Collection` support for diffing
extension TableSectionViewModel: Collection {

    /// :nodoc:
    public subscript(position: Int) -> TableCellViewModel {
        return self.cellViewModels[position]
    }

    /// :nodoc:
    public func index(after i: Int) -> Int {
        return self.cellViewModels.index(after: i)
    }

    /// :nodoc:
    public var startIndex: Int {
        return self.cellViewModels.startIndex
    }

    /// :nodoc:
    public var endIndex: Int {
        return self.cellViewModels.endIndex
    }
}

/// The view model that describes a `UITableView`.
public struct TableViewModel {

    /// The section index titles for this table view.
    public let sectionIndexTitles: [String]?

    /// The section view models for this table view.
    public let sectionModels: [TableSectionViewModel]

    /// Returns `true` if this table has all empty sections.
    public var isEmpty: Bool {
        return self.sectionModels.first(where: { !$0.isEmpty }) == nil
    }

    /// Initializes a table view model with one section and the cell models provided
    /// via the initializer.
    ///
    /// - Parameter cellViewModels: the cell models for the only section in this table.
    public init(cellViewModels: [TableCellViewModel]) {
        let section = TableSectionViewModel(cellViewModels: cellViewModels, diffingKey: "default_section")
        self.init(sectionModels: [section])
    }

    /// Initializes a table view model with the sections provided.
    /// Optionally accepts the `sectionIndexTitles` for this table view.
    ///
    /// - Parameters:
    ///   - sectionModels: the sections that need to be shown in this table view.
    ///   - sectionIndexTitles: the section index titles for this table view.
    public init(sectionModels: [TableSectionViewModel], sectionIndexTitles: [String]? = nil) {
        self.sectionModels = sectionModels
        self.sectionIndexTitles = sectionIndexTitles
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
            section.cellViewModels.count > indexPath.row else { return nil }
        return section.cellViewModels[indexPath.row]
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
