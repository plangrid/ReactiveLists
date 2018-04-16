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

final class TableViewDriverTests: XCTestCase {

    private var _tableView: TestTableView!
    private var _tableViewModel: TableViewModel!
    private var _tableViewDataSource: TableViewDriver!

    override func setUp() {
        super.setUp()
        self._tableView = TestTableView()
        self.setupWithTableView(self._tableView)
    }

    /// Helper method to configure a `TableViewDataSource`
    /// and a `UITableView`.
    /// - Parameter tableView: The `UITableView` that is used to present
    /// the content described in the `TableViewModel`.
    private func setupWithTableView(_ tableView: UITableView) {
        self._tableViewModel = TableViewModel(sectionModels: [
            TableSectionViewModel(
                cellViewModels: [],
                headerViewModel: TestHeaderFooterViewModel(height: 10, viewKind: .header, label: "A"),
                footerViewModel: TestHeaderFooterViewModel(height: 11, viewKind: .footer, label: "A"),
                collapsed: false),
            TableSectionViewModel(
                cellViewModels: ["A", "B", "C"].map { _generateTestCellViewModel($0) },
                headerViewModel: nil,
                footerViewModel: TestHeaderFooterViewModel(title: "footer_2", height: 21),
                collapsed: false),
             TableSectionViewModel(
                cellViewModels: ["D", "E", "F"].map { _generateTestCellViewModel($0) },
                headerViewModel: TestHeaderFooterViewModel(title: "header_3", height: 30),
                footerViewModel: nil,
                collapsed: true),
            ], sectionIndexTitles: ["A", "Z", "Z"])
        self._tableViewDataSource = TableViewDriver(
            tableView: tableView,
            automaticDiffingEnabled: false
        )
        self._tableViewDataSource.tableViewModel = self._tableViewModel
    }

    /// Table view sections described in the table view model are converted into views correctly.
    func testTableViewSections() {

        XCTAssertEqual(self._tableViewDataSource.sectionIndexTitles(for: self._tableView)!, ["A", "Z", "Z"])

        XCTAssertEqual(self._tableViewDataSource.numberOfSections(in: self._tableView), 3)

        parameterize(cases: (0, 10), (1, CGFloat.leastNormalMagnitude), (2, 30), (9, CGFloat.leastNormalMagnitude)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, heightForHeaderInSection: $0), $1)
        }

        parameterize(cases: (0, 11), (1, 21), (2, CGFloat.leastNormalMagnitude), (9, CGFloat.leastNormalMagnitude)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, heightForFooterInSection: $0), $1)
        }

        parameterize(cases: (0, nil), (1, nil), (2, "header_3"), (9, nil)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, titleForHeaderInSection: $0), $1)
        }

        parameterize(cases: (0, nil), (1, "footer_2"), (2, nil), (9, nil)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, titleForFooterInSection: $0), $1)
        }

        parameterize(cases: (0, 0), (1, 3), (2, 0), (9, 0)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, numberOfRowsInSection: $0), $1)
        }
    }

    /// Table view rows described in the table view model are converted into views correctly.
    func testTableViewRows() {
        parameterize(cases: (0, 44), (1, 42), (2, 42), (9, 44)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, heightForRowAt: path($0)), $1)
        }

        parameterize(cases: (0, UITableViewCellEditingStyle.none), (1, .delete), (2, .delete), (9, .none)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, editingStyleForRowAt: path($0)), $1)
        }

        parameterize(cases: (0, true), (1, false), (2, false), (9, true)) {
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, shouldHighlightRowAt: path($0)), $1)
            XCTAssertEqual(self._tableViewDataSource.tableView(self._tableView, shouldIndentWhileEditingRowAt: path($0)), $1)
        }
    }

    /// Table view section headers described in the table view model are converted into views correctly.
    func testExistingSectionHeaders() {
        let section = 0
        let indexKey = path(section)
        let header = self._tableViewDataSource._getHeader(section)
        XCTAssertEqual(header?.label, "title_header+A")
        XCTAssertEqual(header?.accessibilityIdentifier, "access_header+0")

        guard let onScreenHeader = self._tableViewDataSource.tableView(self._tableView, viewForHeaderInSection: indexKey.section) as? TestTableViewSectionHeaderFooter else {
            XCTFail("Did not find the on screen TestTableViewSectionHeaderFooter header")
            return
        }
        XCTAssertEqual(onScreenHeader.label, "title_header+A")
        XCTAssertNil(self._tableView.headerView(forSection: indexKey.section))
    }

    /// Table view section footers described in the table view model are converted into views correctly.
    func testExistingSectionFooters() {
        let section = 0
        let indexKey = path(section)
        let footer = self._tableViewDataSource._getFooter(section)
        XCTAssertEqual(footer?.label, "title_footer+A")
        XCTAssertEqual(footer?.accessibilityIdentifier, "access_footer+0")

        guard let onScreenFooter = self._tableViewDataSource.tableView(self._tableView, viewForFooterInSection: indexKey.section) as? TestTableViewSectionHeaderFooter else {
            XCTFail("Did not find the on screen TestTableViewSectionHeaderFooter footer")
            return
        }
        XCTAssertEqual(onScreenFooter.label, "title_footer+A")
        XCTAssertNil(self._tableView.footerView(forSection: indexKey.section))
    }

    /// Table view cells described in the table view model are converted into views correctly.
    func testExistingTableViewCell() {
        let indexPath = path(1, 2)
        let cell = self._tableViewDataSource._getCell(indexPath)
        XCTAssertEqual(cell?.label, "C")
        XCTAssertEqual(cell?.accessibilityIdentifier, "access-1.2")
    }

    /// Views are refreshed upon assigning a new table view model to the
    /// TableViewDataSource.
    func testRefreshAllViewsOnTableViewModelChange() {
        let dataSource = self._tableViewDataSource

        var header0 = dataSource?._getHeader(0)
        var footer0 = dataSource?._getFooter(0)

        XCTAssertEqual(header0?.label, "title_header+A")
        XCTAssertEqual(footer0?.label, "title_footer+A")

        var header1 = dataSource?._getHeader(1)
        var footer1 = dataSource?._getFooter(1)
        var cell10 = dataSource?._getCell(path(1, 0))

        XCTAssertNil(header1?.label)
        XCTAssertNil(footer1?.label)
        XCTAssertEqual(cell10?.label, "A")

        // Changing the table view model should refresh all views
        self._tableViewDataSource.tableViewModel = _generateTestTableViewModelForRefreshingViews()

        header0 = dataSource?._getHeader(0)
        footer0 = dataSource?._getFooter(0)
        let cell00 = dataSource?._getCell(path(0, 0))

        XCTAssertEqual(header0?.label, "title_header+X")
        XCTAssertEqual(footer0?.label, "title_footer+X")
        XCTAssertEqual(cell00?.label, "X")

        XCTAssertEqual(header0?.accessibilityIdentifier, "access_header+0")
        XCTAssertEqual(footer0?.accessibilityIdentifier, "access_footer+0")
        XCTAssertEqual(cell00?.accessibilityIdentifier, "access-0.0")

        header1 = dataSource?._getHeader(1)
        footer1 = dataSource?._getFooter(1)
        cell10 = dataSource?._getCell(path(1, 0))

        XCTAssertEqual(header1?.label, "title_header+Y")
        XCTAssertEqual(footer1?.label, "title_footer+Y")
        XCTAssertEqual(cell10?.label, "Y")

        XCTAssertEqual(header1?.accessibilityIdentifier, "access_header+1")
        XCTAssertEqual(footer1?.accessibilityIdentifier, "access_footer+1")
        XCTAssertEqual(cell10?.accessibilityIdentifier, "access-1.0")
    }

    /// Selected cells are automatically deselected by default.
    func testShouldDeselectUponSelection() {
        let tableView = TestTableView()
        let dataSource = TableViewDriver(tableView: tableView)
        XCTAssertEqual(tableView.callsToDeselect, 0)
        dataSource.tableView(tableView, didSelectRowAt: path(0))
        XCTAssertEqual(tableView.callsToDeselect, 1)
    }

    /// When the option is disabled, selected cells are no longer
    /// immediately deselected.
    func testShouldNotDeselectUponSelection() {
        let tableView = TestTableView()
        let dataSource = TableViewDriver(
            tableView: tableView,
            shouldDeselectUponSelection: false
        )
        XCTAssertEqual(tableView.callsToDeselect, 0)
        dataSource.tableView(tableView, didSelectRowAt: path(0))
        XCTAssertEqual(tableView.callsToDeselect, 0)
    }

    /// Header and footer views should be registered after assigning a `UITableView` to
    /// the `TableViewDataSource`.
    func testRegisteringHeaderAndFooterViewsOnSetup() {
        // Unset the table view from `setUp` and use a different table view for this test
        let tableView = TestTableView()
        self.setupWithTableView(tableView)

        XCTAssertEqual(tableView.callsToRegisterClass.count, 2)
        XCTAssertEqual(tableView.callsToRegisterClass[0].identifier, "HeaderView")
        XCTAssertEqual(tableView.callsToRegisterClass[1].identifier, "FooterView")
        XCTAssert(tableView.callsToRegisterClass[0].viewClass === HeaderView.self)
        XCTAssert(tableView.callsToRegisterClass[1].viewClass === FooterView.self)
    }

    /// Tests that the table view forwards calls it receives for a given row to the affected cell.
    /// Also ensures that cells that don't have a matching index path are not called.
    func testCellCallbacks() {
        // Set up a new table view that contains two mock cells
        let tableView = UITableView()
        let dataSource = TableViewDriver(tableView: tableView, automaticDiffingEnabled: false)
        let cell1 = MockCellViewModel()
        let cell2 = MockCellViewModel()
        let tableViewModel = TableViewModel(cellViewModels: [cell1, cell2])
        dataSource.tableViewModel = tableViewModel

        // Invoke various callbacks for one of the cells
        let indexPath = IndexPath(row: 0, section: 0)
        dataSource.tableView(tableView, willBeginEditingRowAt: indexPath)
        dataSource.tableView(tableView, didEndEditingRowAt: indexPath)
        dataSource.tableView(tableView, commit: .delete, forRowAt: indexPath)
        dataSource.tableView(tableView, didSelectRowAt: indexPath)

        // Ensure that the affected cell gets all calls forwarded
        XCTAssertTrue(cell1.willBeginEditingCalled)
        XCTAssertTrue(cell1.didEndEditingCalled)
        XCTAssertEqual(cell1.commitEditingStyleCalled, .delete)
        XCTAssertTrue(cell1.didSelectCalled)

        // Ensure that the unaffected cell does not receive any calls
        XCTAssertFalse(cell2.willBeginEditingCalled)
        XCTAssertFalse(cell2.didEndEditingCalled)
        XCTAssertNil(cell2.commitEditingStyleCalled)
        XCTAssertFalse(cell2.didSelectCalled)
    }

    /// When providing a cell that implements the minimum protocol requirements,
    /// default values for certain properties are provided.
    func testTableViewCellViewModelDefaults() {
        struct DefaultCellViewModel: TableCellViewModel {
            var accessibilityFormat: CellAccessibilityFormat = "_"
            let registrationInfo = ViewRegistrationInfo(classType: UITableViewCell.self)
            func applyViewModelToCell(_ cell: UITableViewCell) { }
        }

        let defaultCellViewModel = DefaultCellViewModel()

        XCTAssertNil(defaultCellViewModel.willBeginEditing)
        XCTAssertNil(defaultCellViewModel.didEndEditing)
        XCTAssertEqual(defaultCellViewModel.editingStyle, .none)
        XCTAssertEqual(defaultCellViewModel.rowHeight, nil)
        XCTAssertTrue(defaultCellViewModel.shouldHighlight)
        XCTAssertNil(defaultCellViewModel.commitEditingStyle)
        XCTAssertNil(defaultCellViewModel.didSelect)
        XCTAssertNil(defaultCellViewModel.accessoryButtonTapped)
        XCTAssertFalse(defaultCellViewModel.shouldIndentWhileEditing)
    }
}

// MARK: Test data generation

private func _generateTestCellViewModel(_ label: String) -> TestCellViewModel {
    return TestCellViewModel(label: label, registrationInfo: ViewRegistrationInfo(classType: UITableViewCell.self))
}

private func _generateTestTableViewModelForRefreshingViews() -> TableViewModel {
    return TableViewModel(sectionModels: [
        TableSectionViewModel(
            cellViewModels: [_generateTestCellViewModel("X")],
            headerViewModel: TestHeaderFooterViewModel(height: 10, viewKind: .header, label: "X"),
            footerViewModel: TestHeaderFooterViewModel(height: 11, viewKind: .footer, label: "X")),
        TableSectionViewModel(
            cellViewModels: ["Y", "Z"].map { _generateTestCellViewModel($0) },
            headerViewModel: TestHeaderFooterViewModel(height: 20, viewKind: .header, label: "Y"),
            footerViewModel: TestHeaderFooterViewModel(height: 21, viewKind: .footer, label: "Y")),
        ])
}
