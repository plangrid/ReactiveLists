//
//  FluxTableViewDiffingTests.swift
//  ReactiveLists
//
//  Created by Benji Encz on 7/26/17.
//  Copyright © 2017 PlanGrid. All rights reserved.
//

@testable import ReactiveLists
import XCTest

class FluxTableViewDiffingTests: XCTestCase {

    var fluxTableViewDataSource: FluxTableViewDataSource!
    var mockTableView: TestFluxTableView!

    override func setUp() {
        super.setUp()
        self.mockTableView = TestFluxTableView()
        self.fluxTableViewDataSource = FluxTableViewDataSource(
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
        let initialModel = FluxTableViewModel(
            cellViewModels: []
        )

        self.fluxTableViewDataSource.tableViewModel.value = initialModel

        let updatedModel = FluxTableViewModel(
            cellViewModels: [UserCell(user: "TestUser")]
        )

        self.fluxTableViewDataSource.tableViewModel.value = updatedModel

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
        let initialModel = FluxTableViewModel(sectionModels: [
            FluxTableViewModel.SectionModel(
                cellViewModels: [],
                diffingKey: "1"
            ),
            FluxTableViewModel.SectionModel(
                cellViewModels: [],
                diffingKey: "2"
            ),
        ])

        self.fluxTableViewDataSource.tableViewModel.value = initialModel

        let updatedModel = FluxTableViewModel(sectionModels: [
            FluxTableViewModel.SectionModel(
                cellViewModels: [],
                diffingKey: "2"
            ),
        ])

        self.fluxTableViewDataSource.tableViewModel.value = updatedModel

        XCTAssertEqual(self.mockTableView.callsToDeleteSections.count, 1)
        XCTAssertEqual(
            self.mockTableView.callsToDeleteSections[0].sections,
            IndexSet(integer: 0)
        )
    }
}

struct UserCell: FluxTableViewCellViewModel, DiffableViewModel {
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
