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

public typealias CommitEditingStyleClosure = (UITableViewCellEditingStyle) -> Void
public typealias DidSelectClosure = () -> Void
public typealias DidDeleteClosure = () -> Void
public typealias DidDeselectClosure = () -> Void
public typealias WillBeginEditingClosure = () -> Void
public typealias DidEndEditingClosure = () -> Void
public typealias AccessoryButtonTappedClosure = () -> Void

/// View models for the individual cells of a `TableViewDataSource` driven table view
public protocol TableViewCellViewModel {
    /// `TableViewDataSource` will automatically apply an `accessibilityIdentifier` to the cell based on this format
    var accessibilityFormat: CellAccessibilityFormat { get }

    var cellIdentifier: String { get }
    var rowHeight: CGFloat { get }
    var willBeginEditing: WillBeginEditingClosure? { get }
    var didEndEditing: DidEndEditingClosure? { get }
    var editingStyle: UITableViewCellEditingStyle { get }
    var shouldHighlight: Bool { get }
    var commitEditingStyle: CommitEditingStyleClosure? { get }
    var didSelectClosure: DidSelectClosure? { get }
    var accessoryButtonTappedClosure: AccessoryButtonTappedClosure? { get }
    var shouldIndentWhileEditing: Bool { get }

    @discardableResult
    func applyViewModelToCell(_ cell: UITableViewCell) -> UITableViewCell
}

/// Default implementations for the protocol
public extension TableViewCellViewModel {
    var rowHeight: CGFloat {
        return 44.0
    }

    var willBeginEditing: WillBeginEditingClosure? { return nil }
    var didEndEditing: DidEndEditingClosure? { return nil }
    var editingStyle: UITableViewCellEditingStyle { return .none }
    var shouldHighlight: Bool { return true }
    var commitEditingStyle: CommitEditingStyleClosure? { return nil }
    var didSelectClosure: DidSelectClosure? { return nil }
    var accessoryButtonTappedClosure: AccessoryButtonTappedClosure? { return nil }
    var shouldIndentWhileEditing: Bool { return false }
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
        return sectionModels[ifExists: section]
    }

    public subscript(indexPath: IndexPath) -> TableViewCellViewModel? {
        guard let section = self[indexPath.section],
            let cellViewModels = section.cellViewModels, cellViewModels.count > indexPath.row else { return nil }
        return cellViewModels[ifExists: indexPath.row]
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
