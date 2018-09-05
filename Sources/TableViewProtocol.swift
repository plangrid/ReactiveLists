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

/// Protocol that allows ReactiveLists to use a UITableView without knowing about the concrete type
/// This is useful for testing, and it's a step toward having one
protocol TableView: class {

    // MARK: UITableView methods

    var indexPathsForVisibleRows: [IndexPath]? { get }
    func beginUpdates()
    func endUpdates()
    func reloadData()
    func cellForRow(at indexPath: IndexPath) -> UITableViewCell?
    var dataSource: UITableViewDataSource? { get set }
    var delegate: UITableViewDelegate? { get set }
    func headerView(forSection section: Int) -> UITableViewHeaderFooterView?
    func footerView(forSection section: Int) -> UITableViewHeaderFooterView?

    // MARK: DifferenceKit UITableView extensions

    //swiftlint:disable:next function_parameter_count
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        deleteRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        interrupt: ((Changeset<C>) -> Bool)?,
        setData: (C) -> Void
    )
}

extension TableView {

    //swiftlint:disable:next function_parameter_count
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        deleteRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        setData: (C) -> Void
    ) {
        self.reload(
            using: stagedChangeset,
            deleteSectionsAnimation: deleteSectionsAnimation,
            insertSectionsAnimation: insertRowsAnimation,
            reloadSectionsAnimation: reloadSectionsAnimation,
            deleteRowsAnimation: deleteRowsAnimation,
            insertRowsAnimation: insertRowsAnimation,
            reloadRowsAnimation: reloadRowsAnimation,
            interrupt: nil,
            setData: setData
        )
    }
}

extension UITableView: TableView {}
