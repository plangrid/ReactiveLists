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
import ReactiveSwift
import XCTest

final class TableViewDataSourceTests: XCTestCase {

    private var _tableView: TestTableView!
    private var _tableViewModel: TableViewModel!
    private var _tableViewDataSource: TableViewDataSource!

    private var _lastBeginEditingClosureCaller: String?
    private var _lastEndEditingClosureCaller: String?
    private var _lastCommitEditingStyleClosureCaller: String?
    private var _lastSelectClosureCaller: String?

    override func setUp() {
        super.setUp()
        self._tableView = TestTableView()
        self.setupWithTableView(self._tableView)
    }

    private func setupWithTableView(_ tableView: UITableView) {
        self._tableViewModel = TableViewModel(sectionModels: [
            TableViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestHeaderFooterViewModel(height: 10, viewKind: .header, label: "A"),
                footerViewModel: TestHeaderFooterViewModel(height: 11, viewKind: .footer, label: "A"),
                collapsed: false),
            TableViewModel.SectionModel(
                cellViewModels: ["A", "B", "C"].map { self._generateTestCellViewModel($0) },
                headerViewModel: nil,
                footerViewModel: TestHeaderFooterViewModel(title: "footer_2", height: 21),
                collapsed: false),
            TableViewModel.SectionModel(
                cellViewModels: ["D", "E", "F"].map { self._generateTestCellViewModel($0) },
                headerViewModel: TestHeaderFooterViewModel(title: "header_3", height: 30),
                footerViewModel: nil,
                collapsed: true),
            ], sectionIndexTitles: ["A", "Z", "Z"])
        self._tableViewDataSource = TableViewDataSource(tableView: tableView)
        self._tableViewDataSource.tableViewModel.value = self._tableViewModel
    }

    func testTableViewSetup() {
        // Unset the table view from `setUp` and use a different table view for this test
        let tableView = TestTableView()
        self.setupWithTableView(tableView)

        XCTAssertEqual(tableView.callsToRegisterClass.count, 2)
        XCTAssertEqual(tableView.callsToRegisterClass[0].identifier, "reuse_header+A")
        XCTAssertEqual(tableView.callsToRegisterClass[1].identifier, "reuse_footer+A")
        XCTAssert(tableView.callsToRegisterClass[0].viewClass === HeaderView.self)
        XCTAssert(tableView.callsToRegisterClass[1].viewClass === FooterView.self)
    }

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

    func testNonExistingSectionHeaderFooters() {
        parameterize(cases: 1, 2, 9) {
            XCTAssertNil(self._tableViewDataSource._getHeader($0))
            XCTAssertNil(self._tableViewDataSource._getFooter($0))
        }
    }

    func testExistingSectionHeaders() {
        let section = 0
        let indexKey = path(section)
        let header = self._tableViewDataSource._getHeader(section)
        XCTAssertEqual(header?.label, "title_header+A")
        XCTAssertEqual(header?.accessibilityIdentifier, "access_header+0")

        guard let onScreenHeader = self._tableViewDataSource.headersOnScreen[indexKey] as? TestTableViewSectionHeaderFooter else {
            XCTFail("Did not find the on screen TestTableViewSectionHeaderFooter header")
            return
        }
        XCTAssertEqual(onScreenHeader.label, "title_header+A")

        self._tableViewDataSource.tableView(self._tableView, didEndDisplayingHeaderView: onScreenHeader, forSection: section)
        XCTAssertNil(self._tableViewDataSource.headersOnScreen[indexKey])
    }

    func testExistingSectionFooters() {
        let section = 0
        let indexKey = path(section)
        let footer = self._tableViewDataSource._getFooter(section)
        XCTAssertEqual(footer?.label, "title_footer+A")
        XCTAssertEqual(footer?.accessibilityIdentifier, "access_footer+0")

        guard let onScreenFooter = self._tableViewDataSource.footersOnScreen[indexKey] as? TestTableViewSectionHeaderFooter else {
            XCTFail("Did not find the on screen TestTableViewSectionHeaderFooter footer")
            return
        }
        XCTAssertEqual(onScreenFooter.label, "title_footer+A")

        self._tableViewDataSource.tableView(self._tableView, didEndDisplayingFooterView: onScreenFooter, forSection: section)
        XCTAssertNil(self._tableViewDataSource.footersOnScreen[indexKey])
    }

    func testNonExistingTableViewCells() {
        parameterize(cases: path(0, 0), path(1, 9), path(9, 0)) {
            XCTAssertNil(self._tableViewDataSource._getCell($0))
        }
    }

    func testExistingTableViewCell() {
        let indexPath = path(1, 2)
        let cell = self._tableViewDataSource._getCell(indexPath)
        XCTAssertEqual(cell?.label, "C")
        XCTAssertEqual(cell?.accessibilityIdentifier, "access-1.2")
    }

    func testCellCallbacks() {
        let dataSource = self._tableViewDataSource

        parameterize(cases: (0, nil), (9, nil), (1, "A")) { (section: Int, caller: String?) in
            let indexPath = path(section)
            dataSource?.tableView(self._tableView, willBeginEditingRowAt: indexPath)
            dataSource?.tableView(self._tableView, didEndEditingRowAt: indexPath)
            dataSource?.tableView(self._tableView, commit: .delete, forRowAt: indexPath)
            dataSource?.tableView(self._tableView, didSelectRowAt: indexPath)

            XCTAssertEqual(self._lastBeginEditingClosureCaller, caller)
            XCTAssertEqual(self._lastEndEditingClosureCaller, caller)
            XCTAssertEqual(self._lastCommitEditingStyleClosureCaller, caller)
            XCTAssertEqual(self._lastSelectClosureCaller, caller)
        }
    }

    func testRefreshAllViewsOnTableViewModelChange() {
        let ftvds = self._tableViewDataSource
        var cell10 = ftvds?._getCell(path(1, 0))
        let header0 = ftvds?._getHeader(0)
        let footer0 = ftvds?._getFooter(0)
        var cell00 = ftvds?._getCell(path(0, 0))
        var header1 = ftvds?._getHeader(1)
        var footer1 = ftvds?._getFooter(1)

        XCTAssertEqual(cell10?.label, "A")
        XCTAssertEqual(header0?.label, "title_header+A")
        XCTAssertEqual(footer0?.label, "title_footer+A")
        XCTAssertNil(cell00?.label)
        XCTAssertNil(header1?.label)
        XCTAssertNil(footer1?.label)

        // Changing the table view model should refresh all views
        self._tableViewDataSource.tableViewModel.value = self._generateTestTableViewModelForRefreshingViews()

        cell10 = ftvds?._getCell(path(1, 0))
        cell00 = ftvds?._getCell(path(0, 0))
        header1 = ftvds?._getHeader(1)
        footer1 = ftvds?._getFooter(1)

        XCTAssertEqual(cell10?.label, "Y")

        let headerPredicate = NSPredicate { (header, _) -> Bool in
            return (header as! TestTableViewSectionHeaderFooter).label == "title_header+X"
        }
        let headerExpectation = XCTNSPredicateExpectation(predicate: headerPredicate, object: header0)

        let footerPredicate = NSPredicate { (footer, _) -> Bool in
            return (footer as! TestTableViewSectionHeaderFooter).label == "title_footer+X"
        }
        let footerExpectation = XCTNSPredicateExpectation(predicate: footerPredicate, object: footer0)

        wait(for: [headerExpectation, footerExpectation], timeout: 5)

        XCTAssertEqual(cell00?.label, "X")
        XCTAssertEqual(header1?.label, "title_header+Y")
        XCTAssertEqual(footer1?.label, "title_footer+Y")

        XCTAssertEqual(cell00?.accessibilityIdentifier, "access-0.0")
        XCTAssertEqual(cell10?.accessibilityIdentifier, "access-1.0")
        XCTAssertEqual(header0?.accessibilityIdentifier, "access_header+0")
        XCTAssertEqual(footer0?.accessibilityIdentifier, "access_footer+0")
        XCTAssertEqual(header1?.accessibilityIdentifier, "access_header+1")
        XCTAssertEqual(footer1?.accessibilityIdentifier, "access_footer+1")
    }

    func testShouldDeselectUponSelection() {
        let tableView = TestTableView()
        let dataSource = TableViewDataSource(tableView: tableView)
        XCTAssertEqual(tableView.callsToDeselect, 0)
        dataSource.tableView(tableView, didSelectRowAt: path(0))
        XCTAssertEqual(tableView.callsToDeselect, 1)
    }

    func testShouldNotDeselectUponSelection() {
        let tableView = TestTableView()
        let dataSource = TableViewDataSource(
            tableView: tableView,
            shouldDeselectUponSelection: false
        )
        XCTAssertEqual(tableView.callsToDeselect, 0)
        dataSource.tableView(tableView, didSelectRowAt: path(0))
        XCTAssertEqual(tableView.callsToDeselect, 0)
    }

    private func _generateTestCellViewModel(_ label: String) -> TestCellViewModel {
        return TestCellViewModel(label: label,
                                 willBeginEditing: { [weak self] in self?._lastBeginEditingClosureCaller = label },
                                 didEndEditing: { [weak self] in self?._lastEndEditingClosureCaller = label },
                                 commitEditingStyle: { [weak self] _ in self?._lastCommitEditingStyleClosureCaller = label },
                                 didSelectClosure: { [weak self] in self?._lastSelectClosureCaller = label })
    }

    private func _generateTestTableViewModelForRefreshingViews() -> TableViewModel {
        return TableViewModel(sectionModels: [
            TableViewModel.SectionModel(
                cellViewModels: [self._generateTestCellViewModel("X")],
                headerViewModel: TestHeaderFooterViewModel(height: 10, viewKind: .header, label: "X"),
                footerViewModel: TestHeaderFooterViewModel(height: 11, viewKind: .footer, label: "X")),
            TableViewModel.SectionModel(
                cellViewModels: ["Y", "Z"].map { self._generateTestCellViewModel($0) },
                headerViewModel: TestHeaderFooterViewModel(height: 20, viewKind: .header, label: "Y"),
                footerViewModel: TestHeaderFooterViewModel(height: 21, viewKind: .footer, label: "Y")),
        ])
    }
}
