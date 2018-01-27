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

/// View model for the individual cells of a `TableViewModel`.
public protocol TableViewCellViewModel {

    /// `TableViewDriver` will automatically apply an `accessibilityIdentifier` to the cell based on this format.
    var accessibilityFormat: CellAccessibilityFormat { get }

    /// The registration info for the cell.
    var registrationInfo: ViewRegistrationInfo { get }

    /// The height of this cell.
    var rowHeight: CGFloat { get }

    /// The editing style for this cell.
    var editingStyle: UITableViewCellEditingStyle { get }

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

/// Default implementations for the protocol.
public extension TableViewCellViewModel {
    var rowHeight: CGFloat {
        return 44.0
    }

    var editingStyle: UITableViewCellEditingStyle { return .none }
    var shouldHighlight: Bool { return true }
    var shouldIndentWhileEditing: Bool { return false }
    var willBeginEditing: WillBeginEditingClosure? { return nil }
    var didEndEditing: DidEndEditingClosure? { return nil }
    var commitEditingStyle: CommitEditingStyleClosure? { return nil }
    var didSelect: DidSelectClosure? { return nil }
    var accessoryButtonTapped: AccessoryButtonTappedClosure? { return nil }
}

/// Protocol that needs to be implemented by table view cell view models
/// that want to provide edit actions.
public protocol TableViewCellModelEditActions {
    var editActions: [UITableViewRowAction] { get }
}

/// Protocol that needs to be implemented by custom header
/// footer view models.
public protocol TableViewSectionHeaderFooterViewModel {

    /// The title of the header
    var title: String? { get }

    /// The height of the header
    var height: CGFloat? { get }

    /// Metadata about the custom view type
    var viewInfo: SupplementaryViewInfo? { get }

    /// Asks the view model to update the header/footer
    /// view with the content in the model.
    /// - Parameter view: the header/footer view
    func applyViewModelToView(_ view: UIView)
}

/// View model for a table view section.
public struct TableViewSectionViewModel {

    /// Cells to be shown in this section.
    public let cellViewModels: [TableViewCellViewModel]

    /// View model for the header of this section.
    public let headerViewModel: TableViewSectionHeaderFooterViewModel?

    /// View model for the footer of this section.
    public let footerViewModel: TableViewSectionHeaderFooterViewModel?

    /// Indicates whether or not this section is collapsed.
    public var collapsed: Bool = false

    /// The key used by the diffing algorithm to uniquely identify this section.
    /// If you are using automatic diffing on the `TableViewDriver` (which is enabled by default)
    /// you are required to provide a key that uniquely identifies this section.
    ///
    /// Typically you want to base this diffing key on data that is stored in the model.
    /// For example:
    ///
    ///      public var diffingKey = { group.identifier }
    public var diffingKey: String?

    /// Returns `true` is the section is empty, `false` otherwise.
    public var isEmpty: Bool {
        return self.cellViewModels.isEmpty
    }

    /// Initializes a `TableViewSectionViewModel`.
    ///
    /// - Parameters:
    ///   - cellViewModels: the cell view models contained in this section.
    ///   - headerViewModel: a header view model for this section (defaults to `nil`).
    ///   - footerViewModel: a footer view model for this section (defaults to `nil`).
    ///   - collapsed: whether or not this section is collapsed (defaults to `false`).
    ///   - diffingKey: the diffing key, or `nil`. Required for automated diffing.
    public init(
        cellViewModels: [TableViewCellViewModel],
        headerViewModel: TableViewSectionHeaderFooterViewModel? = nil,
        footerViewModel: TableViewSectionHeaderFooterViewModel? = nil,
        collapsed: Bool = false,
        diffingKey: String? = nil
    ) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.collapsed = collapsed
        self.diffingKey = diffingKey
    }

    /// Initializes a `TableViewSectionViewModel`.
    ///
    /// - Parameters:
    ///   - headerTitle: title for the header, or `nil`. Setting a title will cause a default header
    ///                  to be added to this section.
    ///   - headerHeight: the height of the default header, if one exists.
    ///   - cellViewModels: the cell view models contained in this section.
    ///   - footerTitle: title for the footer, or `nil`. Setting a title will cause a default footer
    ///                  to be added to this section.
    ///   - footerHeight: the height of the default footer, if one exists.
    ///   - diffingKey: the diffing key, or `nil`. Required for automated diffing.
    public init(
        headerTitle: String?,
        headerHeight: CGFloat?,
        cellViewModels: [TableViewCellViewModel],
        footerTitle: String? = nil,
        footerHeight: CGFloat? = 0,
        diffingKey: String? = nil
    ) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = PlainHeaderFooterViewModel(title: headerTitle, height: headerHeight)
        self.footerViewModel = PlainHeaderFooterViewModel(title: footerTitle, height: footerHeight)
        self.diffingKey = diffingKey
    }
}

/// The view model that describes a `UITableView`.
public struct TableViewModel {

    /// The section index titles for this table view.
    public let sectionIndexTitles: [String]?

    /// The section view models for this table view.
    public let sectionModels: [TableViewSectionViewModel]

    /// Returns `true` if this table has no sections or has a single empty section.
    public var isEmpty: Bool {
        if self.sectionModels.count == 1 {
            return self.sectionModels.first!.isEmpty
        }
        return self.sectionModels.isEmpty
    }

    /// Initializes a table view model with one section and the cell models provided
    /// via the initializer.
    ///
    /// - Parameter cellViewModels: the cell models for the only section in this table.
    public init(cellViewModels: [TableViewCellViewModel]) {
        let section = TableViewSectionViewModel(cellViewModels: cellViewModels, diffingKey: "default_section")
        self.init(sectionModels: [section])
    }

    /// Initializes a table view model with the sections provided.
    /// Optionally accepts the `sectionIndexTitles` for this table view.
    ///
    /// - Parameters:
    ///   - sectionModels: the sections that need to be shown in this table view.
    ///   - sectionIndexTitles: the section index titles for this table view.
    public init(sectionModels: [TableViewSectionViewModel], sectionIndexTitles: [String]? = nil) {
        if let sectionIndexTitles = sectionIndexTitles {
            assert(
                sectionModels.count == sectionIndexTitles.count,
                "The table view model requires an index title per section."
            )
        }
        self.sectionModels = sectionModels
        self.sectionIndexTitles = sectionIndexTitles
    }

    /// Returns the section model at the specified index or `nil` if no such section exists.
    ///
    /// - Parameter section: the index for the section that is being retrieved
    public subscript(section: Int) -> TableViewSectionViewModel? {
        guard sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    /// Returns the cell view model at the specified index path or `nil` if no such cell exists.
    ///
    /// - Parameter indexPath: the index path for the cell that is being retrieved
    public subscript(indexPath: IndexPath) -> TableViewCellViewModel? {
        guard let section = self[indexPath.section],
            section.cellViewModels.count > indexPath.row else {
                return nil
        }
        return section.cellViewModels[indexPath.row]
    }

    /// Provides a description of the table view content in terms of diffing keys. These diffing keys
    /// are used to calculate changesets in the table and animate changes automatically.
    var diffingKeys: SectionedValues<DiffingKey, DiffingKey> {
        return SectionedValues(
            self.sectionModels.map { section in
                // Ensure we have a diffing key for the current section
                guard let sectionDiffingKey = section.diffingKey else {
                    fatalError("When diffing is enabled you need to provide a non-nil diffingKey for each section.")
                }

                // Ensure we have a diffing key for each cell in this section
                let cellDiffingKeys: [DiffingKey] = section.cellViewModels.map { cell in
                    guard let cell = cell as? DiffableViewModel else {
                        fatalError("When diffing is enabled you need to provide cells which are DiffableViews.")
                    }
                    return "\(type(of: cell))_\(cell.diffingKey)"
                }

                return (sectionDiffingKey, cellDiffingKeys)
            }
        )
    }
}

// MARK: Private

/// View model for a default header or footer view in a table view.
private struct PlainHeaderFooterViewModel: TableViewSectionHeaderFooterViewModel {
    let title: String?
    let height: CGFloat?
    let viewInfo: SupplementaryViewInfo? = nil

    func applyViewModelToView(_ view: UIView) {}
}
