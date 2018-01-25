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

/// View models for the individual cells of a `TableViewModel`.
public protocol TableViewCellViewModel {
    /// `TableViewDriver` will automatically apply an `accessibilityIdentifier` to the cell based on this format.
    var accessibilityFormat: CellAccessibilityFormat { get }
    /// The reuse identifier for this cell.
    var cellIdentifier: String { get }
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

/// Default implementations for the protocol
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

public protocol TableViewCellModelEditActions {
    func editActions(_ indexPath: IndexPath) -> [UITableViewRowAction]
}

public protocol TableViewSectionHeaderFooterViewModel {
    var title: String? { get }
    var height: CGFloat? { get }
    var viewInfo: SupplementaryViewInfo? { get }
    func applyViewModelToView(_ view: UIView)
}

public struct TableViewModel {
    public let sectionIndexTitles: [String]?
    public let sectionModels: [SectionModel]

    public var isEmpty: Bool {
        guard let cellViewModels = self.sectionModels.first?.cellViewModels else {
            return self.sectionModels.isEmpty
        }

        return self.sectionModels.count == 1 && cellViewModels.isEmpty
    }

    public init(sectionModels: [SectionModel], sectionIndexTitles: [String]? = nil) {
        self.sectionModels = sectionModels
        self.sectionIndexTitles = sectionIndexTitles
    }

    public init(cellViewModels: [TableViewCellViewModel]?) {
        let section = SectionModel(cellViewModels: cellViewModels, diffingKey: "default_section")
        self.init(sectionModels: [section])
    }

    public subscript(section: Int) -> SectionModel? {
        guard sectionModels.count > section else { return nil }
        return sectionModels[section]
    }

    public subscript(indexPath: IndexPath) -> TableViewCellViewModel? {
        guard let section = self[indexPath.section],
            let cellViewModels = section.cellViewModels,
            cellViewModels.count > indexPath.row else {
                return nil
        }
        return cellViewModels[indexPath.row]
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
                let cellDiffingKeys: [DiffingKey] = section.cellViewModels?.map { cell in
                    guard let cell = cell as? DiffableViewModel else {
                        fatalError("When diffing is enabled you need to provide cells which are DiffableViews.")
                    }
                    return "\(type(of: cell))_\(cell.diffingKey)"
                } ?? []

                return (sectionDiffingKey, cellDiffingKeys)
            }
        )
    }
}

extension TableViewModel {

    public struct SectionModel {
        private struct PlainHeaderFooterViewModel: TableViewSectionHeaderFooterViewModel {
            let title: String?
            let height: CGFloat?
            let viewInfo: SupplementaryViewInfo? = nil

            func applyViewModelToView(_ view: UIView) {}
        }

        public let cellViewModels: [TableViewCellViewModel]?
        public let headerViewModel: TableViewSectionHeaderFooterViewModel?
        public let footerViewModel: TableViewSectionHeaderFooterViewModel?
        public var collapsed: Bool = false
        public var diffingKey: String?

        public init(
            cellViewModels: [TableViewCellViewModel]?,
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

        public init(
            headerTitle: String?,
            headerHeight: CGFloat?,
            cellViewModels: [TableViewCellViewModel]?,
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
}
