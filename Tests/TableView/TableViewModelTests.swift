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

final class TableViewModelTests: XCTestCase {

    /// The table view model allows subscripting into sections and cells.
    /// If the section or cell at the index does not exist, the table view
    /// model returns `nil`.
    func testSubscripts() {
        let tableViewModel = TableViewModel(sectionModels: [
            TableSectionViewModel(
                headerTitle: "section_1",
                headerHeight: 42,
                cellViewModels: []),
            TableSectionViewModel(
                headerTitle: "section_2",
                headerHeight: 43,
                cellViewModels: [
                    generateTestCellViewModel("A"),
                    generateTestCellViewModel("B"),
                    generateTestCellViewModel("C"),
            ]),
        ])

        // Returns `nil` when there's no cell/section at the provided path.
        XCTAssertNil(tableViewModel[ifExists: 9]?.headerViewModel?.title)
        XCTAssertNil(tableViewModel[ifExists: IndexPath(row: 0, section: 0)])
        XCTAssertNil(tableViewModel[ifExists: IndexPath(row: 0, section: 9)])
        XCTAssertNil(tableViewModel[ifExists: IndexPath(row: 9, section: 1)])

        // Returns the section/cell model, if the index path exists within the table view model.
        XCTAssertEqual(tableViewModel[ifExists: 0]?.headerViewModel?.title, "section_1")
        XCTAssertEqual((tableViewModel[ifExists: IndexPath(row: 0, section: 1)] as? TestCellViewModel)?.label, "A")
        XCTAssertNil(tableViewModel[ifExists: [] as IndexPath])
    }

    /// The `.isEmpty` property of the table view.
    func testIsEmpty() {
        let section0 = TableSectionViewModel(cellViewModels: generateTableCellViewModels())
        let sectionEmpty = TableSectionViewModel(cellViewModels: [])
        let section2 = TableSectionViewModel(cellViewModels: generateTableCellViewModels(count: 1))

        let tableViewModel1 = TableViewModel(sectionModels: [])
        XCTAssertTrue(tableViewModel1.isEmpty)

        let tableViewModel2 = TableViewModel(cellViewModels: [])
        XCTAssertTrue(tableViewModel2.isEmpty)

        let tableViewModel3 = TableViewModel(sectionModels: [sectionEmpty, sectionEmpty, sectionEmpty, sectionEmpty])
        XCTAssertTrue(tableViewModel3.isEmpty)

        let tableViewModel4 = TableViewModel(sectionModels: [sectionEmpty, section0, section0, section0])
        XCTAssertFalse(tableViewModel4.isEmpty)

        let tableViewModel5 = TableViewModel(sectionModels: [section2, section0, section0, sectionEmpty])
        XCTAssertFalse(tableViewModel5.isEmpty)

        let tableViewModel6 = TableViewModel(sectionModels: [section0, sectionEmpty, section2])
        XCTAssertFalse(tableViewModel6.isEmpty)
    }

    /// Table view sections can be successfully initialized
    /// using a plain section header.
    func testPlainHeaderFooterSectionModelInitalizer() {
        let sectionModel = TableSectionViewModel(
            headerTitle: "foo",
            headerHeight: 42,
            cellViewModels: [generateTestCellViewModel()],
            footerTitle: "bar",
            footerHeight: 43
        )

        XCTAssertEqual(sectionModel.cellViewModels.count, 1)
        XCTAssertEqual(sectionModel.headerViewModel?.height, 42)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 43)
        XCTAssertEqual(sectionModel.headerViewModel?.title, "foo")
        XCTAssertEqual(sectionModel.footerViewModel?.title, "bar")
        XCTAssertNil(sectionModel.headerViewModel?.viewInfo)
        XCTAssertNil(sectionModel.footerViewModel?.viewInfo)
    }

    /// Table view sections can be successfully initialized
    /// using a custom section header type.
    func testCustomHeaderFooterSectionModelInitalizer() {
        let sectionModel = TableSectionViewModel(
            cellViewModels: [generateTestCellViewModel()],
            headerViewModel: TestHeaderFooterViewModel(height: 42, viewKind: .header, label: "A"),
            footerViewModel: TestHeaderFooterViewModel(height: 43, viewKind: .footer, label: "A"))

        XCTAssertEqual(sectionModel.cellViewModels.count, 1)
        XCTAssertEqual(sectionModel.headerViewModel?.height, 42)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 43)
        XCTAssertEqual(sectionModel.headerViewModel?.title, "title_header+A")
        XCTAssertEqual(sectionModel.footerViewModel?.title, "title_footer+A")

        let headerInfo = sectionModel.headerViewModel?.viewInfo
        let footerInfo = sectionModel.footerViewModel?.viewInfo

        XCTAssertTrue(headerInfo?.registrationInfo.registrationMethod == .fromClass(HeaderView.self))
        XCTAssertTrue(footerInfo?.registrationInfo.registrationMethod == .fromClass(FooterView.self))
        XCTAssertEqual(headerInfo?.registrationInfo.reuseIdentifier, "HeaderView")
        XCTAssertEqual(footerInfo?.registrationInfo.reuseIdentifier, "FooterView")
        XCTAssertEqual(
            headerInfo?.accessibilityFormat.accessibilityIdentifierForSection(44),
            "access_header+44"
        )
        XCTAssertEqual(
            footerInfo?.accessibilityFormat.accessibilityIdentifierForSection(44),
            "access_footer+44"
        )
    }
}
