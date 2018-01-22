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

final class TableViewDiffingTests: XCTestCase {

    var tableViewDataSource: TableViewDataSource!
    var mockTableView: TestTableView!

    override func setUp() {
        super.setUp()
        self.mockTableView = TestTableView()
        self.tableViewDataSource = TableViewDataSource(
            tableView: self.mockTableView,
            automaticDiffEnabled: true,
            shouldDeselectUponSelection: false
        )
    }

    /// Tests that changes to individual rows result in the correct calls to update the
    /// table view.
    ///
    /// - Note: We're only testing one type of row update since this is sufficient to test the
    ///   communication between the diffing lib and the table view. The diffing lib itself has
    ///   extensive tests for the various diffing scenarios.
    func testChangingRows() {
        let initialModel = TableViewModel(
            cellViewModels: []
        )

        self.tableViewDataSource.tableViewModel.value = initialModel

        let updatedModel = TableViewModel(
            cellViewModels: [UserCell(user: "TestUser")]
        )

        self.tableViewDataSource.tableViewModel.value = updatedModel

        XCTAssertEqual(self.mockTableView.callsToInsertRowAtIndexPaths.count, 1)
        XCTAssertEqual(
            self.mockTableView.callsToInsertRowAtIndexPaths[0].indexPaths,
            [IndexPath(row: 0, section: 0)]
        )
    }

    /// Tests that changes to individual sections result in the correct calls to update the
    /// table view.
    ///
    /// - Note: We're only testing one type of section update since this is sufficient to test the
    ///   communication between the diffing lib and the table view. The diffing lib itself has
    ///   extensive tests for the various diffing scenarios.
    func testChangingSections() {
        let initialModel = TableViewModel(sectionModels: [
            TableViewModel.SectionModel(
                cellViewModels: [],
                diffingKey: "1"
            ),
            TableViewModel.SectionModel(
                cellViewModels: [],
                diffingKey: "2"
            ),
        ])

        self.tableViewDataSource.tableViewModel.value = initialModel

        let updatedModel = TableViewModel(sectionModels: [
            TableViewModel.SectionModel(
                cellViewModels: [],
                diffingKey: "2"
            ),
        ])

        self.tableViewDataSource.tableViewModel.value = updatedModel

        XCTAssertEqual(self.mockTableView.callsToDeleteSections.count, 1)
        XCTAssertEqual(
            self.mockTableView.callsToDeleteSections[0].sections,
            IndexSet(integer: 0)
        )
    }
}

struct UserCell: TableViewCellViewModel, DiffableViewModel {
    var accessibilityFormat: CellAccessibilityFormat = ""
    let cellIdentifier = "UserCell"

    let user: String

    init(user: String) {
        self.user = user
    }

    func applyViewModelToCell(_ cell: UITableViewCell) -> UITableViewCell {
        return cell
    }

    var diffingKey: String {
        return self.user
    }
}
