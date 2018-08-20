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

final class CollectionViewModelTests: XCTestCase {

    /// Can be initialized with a custom header and footer view.
    func testViewModelInitializerWithCustomHeaderAndFooter() {
        let sectionModel = CollectionSectionViewModel(
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

        XCTAssertEqual(sectionModel.cellViewModels.count, 1)

        XCTAssertEqual(sectionModel.headerViewModel?.height, 40)
        XCTAssertEqual(sectionModel.footerViewModel?.height, 50)

        let headerViewInfo = sectionModel.headerViewModel?.viewInfo
        XCTAssertTrue(headerViewInfo?.registrationInfo.registrationMethod == .fromClass(HeaderView.self))
        XCTAssertEqual(headerViewInfo?.registrationInfo.reuseIdentifier, "HeaderView")
        XCTAssertEqual(headerViewInfo?.accessibilityFormat.accessibilityIdentifierForSection(84), "access_header+84")

        let footerViewInfo = sectionModel.footerViewModel?.viewInfo
        XCTAssertTrue(footerViewInfo?.registrationInfo.registrationMethod == .fromClass(FooterView.self))
        XCTAssertEqual(footerViewInfo?.registrationInfo.reuseIdentifier, "FooterView")
        XCTAssertEqual(footerViewInfo?.accessibilityFormat.accessibilityIdentifierForSection(84), "access_footer+84")
    }

    /// The table view model allows subscripting into sections and cells.
    /// If the section or cell at the index does not exist, the table view
    /// model returns `nil`.
    func testSubscripts() {
        let collectionViewModel = CollectionViewModel(sectionModels: [
            CollectionSectionViewModel(cellViewModels: []),
            CollectionSectionViewModel(
                cellViewModels: [
                    generateTestCollectionCellViewModel("A"),
                    generateTestCollectionCellViewModel("B"),
                    generateTestCollectionCellViewModel("C"),
                ]),
        ])

        // Returns `nil` when there's no cell/section at the provided path.
        XCTAssertNil(collectionViewModel[ifExists: 9]?.headerViewModel?.height)
        XCTAssertNil(collectionViewModel[ifExists: IndexPath(row: 0, section: 0)])
        XCTAssertNil(collectionViewModel[ifExists: IndexPath(row: 0, section: 9)])
        XCTAssertNil(collectionViewModel[ifExists: IndexPath(row: 9, section: 1)])

        // Returns the section/cell model, if the index path exists within the table view model.
        let cell_row_0_section_1 = collectionViewModel[ifExists: IndexPath(row: 0, section: 1)]
            as? TestCollectionCellViewModel
        XCTAssertEqual(cell_row_0_section_1?.label, "A")
    }

    /// The `.isEmpty` property of the collection view.
    func testIsEmpty() {
        let section0 = CollectionSectionViewModel(cellViewModels: generateCollectionCellViewModels())
        let sectionEmpty = CollectionSectionViewModel(cellViewModels: [])
        let section2 = CollectionSectionViewModel(cellViewModels: generateCollectionCellViewModels(count: 1))

        let viewModel1 = CollectionViewModel(sectionModels: [])
        XCTAssertTrue(viewModel1.isEmpty)

        let viewModel2 = CollectionViewModel(sectionModels: [sectionEmpty, sectionEmpty, sectionEmpty, sectionEmpty])
        XCTAssertTrue(viewModel2.isEmpty)

        let viewModel3 = CollectionViewModel(sectionModels: [sectionEmpty, section0, section0, section0])
        XCTAssertFalse(viewModel3.isEmpty)

        let viewModel4 = CollectionViewModel(sectionModels: [section2, section0, section0, sectionEmpty])
        XCTAssertFalse(viewModel4.isEmpty)

        let viewModel5 = CollectionViewModel(sectionModels: [section0, sectionEmpty, section2])
        XCTAssertFalse(viewModel5.isEmpty)
    }
}
