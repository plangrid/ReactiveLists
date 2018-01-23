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

final class CollectionViewModelTests: XCTestCase {

    /// Can be initialized by specifying a header and footer height,
    /// without specifying a header and footer view, wich results
    /// in a blank default view being used.
    func testViewModelInitalizerWithBlankHeaderAndFooter() {
        let sectionModel = CollectionViewModel.SectionModel(
            cellViewModels: [generateTestCollectionCellViewModel()],
            headerHeight: 40,
            footerHeight: 50
        )

        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)
        XCTAssertEqual(sectionModel.headerViewModel?.height, 40)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 50)
        XCTAssertNil(sectionModel.headerViewModel?.viewInfo)
        XCTAssertNil(sectionModel.footerViewModel?.viewInfo)
    }

    /// Can be initialized by specifying a header height,
    /// without specifying a header view, wich results
    /// in a blank default view being used.
    func testViewModelInitializerWithBlankHeader() {
        let sectionModel = CollectionViewModel.SectionModel(
            cellViewModels: [generateTestCollectionCellViewModel()],
            headerHeight: 40,
            footerViewModel: TestCollectionViewSupplementaryViewModel(
                height: 50,
                viewKind: .footer,
                sectionLabel: "A"
            )
        )

        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)
        XCTAssertNil(sectionModel.headerViewModel?.viewInfo)

        XCTAssertEqual(sectionModel.headerViewModel?.height, 40)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 50)

        let viewInfo = sectionModel.footerViewModel?.viewInfo
        XCTAssertTrue(viewInfo?.registrationMethod == .viewClass(FooterView.self))
        XCTAssertEqual(viewInfo?.reuseIdentifier, "reuse_footer+A")
        XCTAssertEqual(viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(84), "access_footer+84")
    }

    /// Can be initialized by specifying a footer height,
    /// without specifying a footer view, wich results
    /// in a blank default view being used.
    func testViewModelInitializerWithBlankFooter() {
        let sectionModel = CollectionViewModel.SectionModel(
            cellViewModels: [generateTestCollectionCellViewModel()],
            headerViewModel: TestCollectionViewSupplementaryViewModel(
                height: 40,
                viewKind: .header,
                sectionLabel: "A"
            ),
            footerHeight: 50
        )

        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)
        XCTAssertNil(sectionModel.footerViewModel?.viewInfo)

        XCTAssertEqual(sectionModel.headerViewModel?.height, 40)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 50)

        let viewInfo = sectionModel.headerViewModel?.viewInfo
        XCTAssertTrue(viewInfo?.registrationMethod == .viewClass(HeaderView.self))
        XCTAssertEqual(viewInfo?.reuseIdentifier, "reuse_header+A")
        XCTAssertEqual(viewInfo?.accessibilityFormat.accessibilityIdentifierForSection(84), "access_header+84")
    }

    /// Can be initialized with a custom header and footer view.
    func testViewModelInitializerWithCustomHeaderAndFooter() {
        let sectionModel = CollectionViewModel.SectionModel(
            cellViewModels: [generateTestCollectionCellViewModel()],
            headerViewModel: TestCollectionViewSupplementaryViewModel(
                height: 40,
                viewKind: .header,
                sectionLabel: "A"
            ),
            footerViewModel: TestCollectionViewSupplementaryViewModel(
                height: 50,
                viewKind: .footer,
                sectionLabel: "A"
            )
        )

        XCTAssertEqual(sectionModel.cellViewModels?.count, 1)

        XCTAssertEqual(sectionModel.headerViewModel?.height, 40)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 50)

        let headerViewInfo = sectionModel.headerViewModel?.viewInfo
        XCTAssertTrue(headerViewInfo?.registrationMethod == .viewClass(HeaderView.self))
        XCTAssertEqual(headerViewInfo?.reuseIdentifier, "reuse_header+A")
        XCTAssertEqual(headerViewInfo?.accessibilityFormat.accessibilityIdentifierForSection(84), "access_header+84")

        let footerViewInfo = sectionModel.footerViewModel?.viewInfo
        XCTAssertTrue(footerViewInfo?.registrationMethod == .viewClass(FooterView.self))
        XCTAssertEqual(footerViewInfo?.reuseIdentifier, "reuse_footer+A")
        XCTAssertEqual(footerViewInfo?.accessibilityFormat.accessibilityIdentifierForSection(84), "access_footer+84")
    }

    /// The table view model allows subscripting into sections and cells.
    /// If the section or cell at the index does not exist, the table view
    /// model returns `nil`.
    func testSubscripts() {
        let collectionViewModel = CollectionViewModel(sectionModels: [
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerHeight: 42,
                footerHeight: nil),
            CollectionViewModel.SectionModel(
                cellViewModels: [
                    generateTestCollectionCellViewModel("A"),
                    generateTestCollectionCellViewModel("B"),
                    generateTestCollectionCellViewModel("C"),
                ],
                headerHeight: 43,
                footerHeight: nil),
        ])

        // Returns `nil` when there's no cell/section at the provided path.
        XCTAssertNil(collectionViewModel[9]?.headerViewModel?.height)
        XCTAssertNil(collectionViewModel[IndexPath(row: 0, section: 0)])
        XCTAssertNil(collectionViewModel[IndexPath(row: 0, section: 9)])
        XCTAssertNil(collectionViewModel[IndexPath(row: 9, section: 1)])

        // Returns the section/cell model, if the index path exists within the table view model.
        XCTAssertEqual(collectionViewModel[0]?.headerViewModel?.height, 42)
        let cell_row_0_section_1 = collectionViewModel[IndexPath(row: 0, section: 1)]
            as? TestCollectionCellViewModel
        XCTAssertEqual(cell_row_0_section_1?.label, "A")
    }

}

