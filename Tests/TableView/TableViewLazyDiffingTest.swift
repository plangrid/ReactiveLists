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

@testable import ReactiveLists
import XCTest

final class TableViewLazyDiffingTests: XCTestCase {

    var tableViewDataSource: TableViewDriver!
    var mockTableView: TestTableView!

    override func setUp() {
        super.setUp()
        self.mockTableView = TestTableView()
        self.mockTableView.indexPathsForVisibleRowsOverride = [
            IndexPath(row: 0, section: 0),
        ]
        self.tableViewDataSource = TableViewDriver(
            tableView: self.mockTableView,
            shouldDeselectUponSelection: false,
            automaticDiffingEnabled: true
        )
    }

    /// Tests that changes to individual rows result in the correct calls to update the
    /// table view.
    ///
    /// - Note: We're only testing one type of row update since this is sufficient to test the
    ///   communication between the diffing lib and the table view. The diffing lib itself has
    ///   extensive tests for the various diffing scenarios.
    func testChangingRows() {
        let userCell = LazyUserCell(user: "Name")
        let initialModel = TableViewModel(
            cellViewModels: [userCell]
        )

        self.tableViewDataSource.tableViewModel = initialModel

        let testUser1 = LazyUserCell(user: "TestUser1")
        let testUser2 = LazyUserCell(user: "TestUser2")
        let updatedModel = TableViewModel(
            cellViewModels: [
                userCell,
                testUser1,
                testUser2,
            ]
        )

        self.tableViewDataSource.tableViewModel = updatedModel

        XCTAssertEqual(self.mockTableView.callsToInsertRowAtIndexPaths.count, 1)
        XCTAssertEqual(self.mockTableView.callsToInsertRowAtIndexPaths[0].indexPaths, [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)])
    }
}

final class LazyUserCell: TableCellViewModel, DiffableViewModel {
    var accessibilityFormat: CellAccessibilityFormat = ""
    let registrationInfo = ViewRegistrationInfo(classType: UITableViewCell.self)

    let user: String
    private(set) var diffingKeyAccessed: Bool = false

    init(user: String) {
        self.user = user
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {}

    func willDisplay(cell: UITableViewCell) {}

    var diffingKey: String {
        self.diffingKeyAccessed = true
        return self.user
    }
}
