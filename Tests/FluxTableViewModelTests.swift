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

final class FluxTableViewModelTests: XCTestCase {
    private var _tableViewModel: FluxTableViewModel!

    func testPlainHeaderFooterSectionModelInitalizer() {
        let sectionModel = FluxTableViewModel.SectionModel(
            headerTitle: "foo",
            headerHeight: 42,
            cellViewModels: [generateRandomTestCellViewModel()],
            footerTitle: "bar",
            footerHeight: 43)

        self.runCommonSectionModelAttributeTests(sectionModel)

        XCTAssertFalse(sectionModel.collapsed)
        XCTAssertEqual(sectionModel.headerViewModel?.title, "foo")
        XCTAssertEqual(sectionModel.footerViewModel?.title, "bar")
        XCTAssertNil(sectionModel.headerViewModel?.viewInfo)
        XCTAssertNil(sectionModel.footerViewModel?.viewInfo)
    }

    func testCustomHeaderFooterSectionModelInitalizer() {
        let sectionModel = FluxTableViewModel.SectionModel(cellViewModels: [generateRandomTestCellViewModel()],
                                                           headerViewModel: TestHeaderFooterViewModel(height: 42, viewKind: .header, label: "A"),
                                                           footerViewModel: TestHeaderFooterViewModel(height: 43, viewKind: .footer, label: "A"),
                                                           collapsed: true)

        self.runCommonSectionModelAttributeTests(sectionModel)

        XCTAssertEqual(sectionModel.headerViewModel?.title, "title_header+A")
        XCTAssertEqual(sectionModel.footerViewModel?.title, "title_footer+A")

        let headerInfo = sectionModel.headerViewModel?.viewInfo
        let footerInfo = sectionModel.footerViewModel?.viewInfo

        XCTAssertTrue(sectionModel.collapsed)
        XCTAssertTrue(headerInfo?.registrationMethod == .viewClass(HeaderView.self))
        XCTAssertTrue(footerInfo?.registrationMethod == .viewClass(FooterView.self))
        XCTAssertEqual(headerInfo?.reuseIdentifier, "reuse_header+A")
        XCTAssertEqual(footerInfo?.reuseIdentifier, "reuse_footer+A")
        XCTAssertEqual(headerInfo?.accessibilityFormat.accessibilityIdentifierForSection(44), "access_header+44")
        XCTAssertEqual(footerInfo?.accessibilityFormat.accessibilityIdentifierForSection(44), "access_footer+44")
    }

    func testSubscripts() {
        let tableViewModel = FluxTableViewModel(sectionModels: [
            FluxTableViewModel.SectionModel(
                headerTitle: "section_1",
                headerHeight: 42,
                cellViewModels: nil),
            FluxTableViewModel.SectionModel(
                headerTitle: "section_2",
                headerHeight: 43,
                cellViewModels: [
                    generateRandomTestCellViewModel("A"),
                    generateRandomTestCellViewModel("B"),
                    generateRandomTestCellViewModel("C"),
            ]),
        ])

        XCTAssertNil(tableViewModel[9]?.headerViewModel?.title)
        XCTAssertEqual(tableViewModel[0]?.headerViewModel?.title, "section_1")

        XCTAssertNil(tableViewModel[path(0, 0)])
        XCTAssertNil(tableViewModel[path(9, 0)])
        XCTAssertNil(tableViewModel[path(1, 9)])
        XCTAssertEqual((tableViewModel[path(1, 0)] as? TestCellViewModel)?.label, "A")
    }

    func runCommonSectionModelAttributeTests(_ sectionModel: FluxTableViewModel.SectionModel) {
        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)
        XCTAssertEqual(sectionModel.headerViewModel?.height, 42)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 43)
    }
}
