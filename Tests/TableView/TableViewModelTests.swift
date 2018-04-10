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
            TableViewModel.SectionModel(
                headerTitle: "section_1",
                headerHeight: 42,
                cellViewModels: nil),
            TableViewModel.SectionModel(
                headerTitle: "section_2",
                headerHeight: 43,
                cellViewModels: [
                    generateTestCellViewModel("A"),
                    generateTestCellViewModel("B"),
                    generateTestCellViewModel("C"),
            ]),
        ])

        // Returns `nil` when there's no cell/section at the provided path.
        XCTAssertNil(tableViewModel[9]?.headerViewModel?.title)
        XCTAssertNil(tableViewModel[IndexPath(row: 0, section: 0)])
        XCTAssertNil(tableViewModel[IndexPath(row: 0, section: 9)])
        XCTAssertNil(tableViewModel[IndexPath(row: 9, section: 1)])

        // Returns the section/cell model, if the index path exists within the table view model.
        XCTAssertEqual(tableViewModel[0]?.headerViewModel?.title, "section_1")
        XCTAssertEqual((tableViewModel[IndexPath(row: 0, section: 1)] as? TestCellViewModel)?.label, "A")
        XCTAssertNil(tableViewModel[[] as IndexPath])
    }

    /// The `.isEmpty` property of the table view returns `true` when the table view
    /// contains no sections or one section with no cells.
    func testIsEmpty() {
        let tableViewModel1 = TableViewModel(sectionModels: [])
        XCTAssertTrue(tableViewModel1.isEmpty)

        let tableViewModel2 = TableViewModel(
            sectionModels: [TableViewModel.SectionModel(
                cellViewModels: []
            )]
        )

        XCTAssertTrue(tableViewModel1.isEmpty)
        XCTAssertTrue(tableViewModel2.isEmpty)
    }

    /// Table view sections can be successfully initialized
    /// using a plain section header.
    func testPlainHeaderFooterSectionModelInitalizer() {
        let sectionModel = TableViewModel.SectionModel(
            headerTitle: "foo",
            headerHeight: 42,
            cellViewModels: [generateTestCellViewModel()],
            footerTitle: "bar",
            footerHeight: 43
        )

        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)
        XCTAssertEqual(sectionModel.headerViewModel?.height, 42)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 43)
        XCTAssertFalse(sectionModel.collapsed)
        XCTAssertEqual(sectionModel.headerViewModel?.title, "foo")
        XCTAssertEqual(sectionModel.footerViewModel?.title, "bar")
        XCTAssertNil(sectionModel.headerViewModel?.viewInfo)
        XCTAssertNil(sectionModel.footerViewModel?.viewInfo)
    }


    /// Table view sections can be successfully initialized
    /// using a custom section header type.
    func testCustomHeaderFooterSectionModelInitalizer() {
        let sectionModel = TableViewModel.SectionModel(
            cellViewModels: [generateTestCellViewModel()],
            headerViewModel: TestHeaderFooterViewModel(height: 42, viewKind: .header, label: "A"),
            footerViewModel: TestHeaderFooterViewModel(height: 43, viewKind: .footer, label: "A"),
            collapsed: true
        )

        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)
        XCTAssertEqual(sectionModel.headerViewModel?.height, 42)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 43)
        XCTAssertEqual(sectionModel.headerViewModel?.title, "title_header+A")
        XCTAssertEqual(sectionModel.footerViewModel?.title, "title_footer+A")

        let headerInfo = sectionModel.headerViewModel?.viewInfo
        let footerInfo = sectionModel.footerViewModel?.viewInfo

        XCTAssertTrue(sectionModel.collapsed)
        XCTAssertTrue(headerInfo?.registrationMethod == .viewClass(HeaderView.self))
        XCTAssertTrue(footerInfo?.registrationMethod == .viewClass(FooterView.self))
        XCTAssertEqual(headerInfo?.reuseIdentifier, "reuse_header+A")
        XCTAssertEqual(footerInfo?.reuseIdentifier, "reuse_footer+A")
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
