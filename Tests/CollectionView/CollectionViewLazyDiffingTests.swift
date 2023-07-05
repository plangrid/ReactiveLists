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

final class CollectionViewDiffingTests: XCTestCase {

    var collectionViewDataSource: CollectionViewDriver!
    var mockCollectionView: TestCollectionView!

    override func setUp() {
        super.setUp()
        self.mockCollectionView = TestCollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
//        self.mockCollectionView.indexPathsForVisibleRowsOverride = [
//            IndexPath(row: 0, section: 0),
//        ]
        self.collectionViewDataSource = CollectionViewDriver(
            collectionView: self.mockCollectionView,
            shouldDeselectUponSelection: false,
            useDataSource: true,
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
        let userCells = [LazyTestUserCell(user: "Name")]
        let dataSource = CollectionCellViewModelDataSource(userCells)
        let section = CollectionSectionViewModel(
            diffingKey: "default_section",
            cellViewModels: [],
            cellViewModelDataSource: dataSource
        )
        let initialModel = CollectionViewModel(
            sectionModels: [section]
        )

        self.collectionViewDataSource.collectionViewModel = initialModel

        let testUser1 = [LazyTestUserCell(user: "TestUser1")]
//        [LazyUserCell(user: "TestUser1"), LazyUserCell(user: "TestUser2")]
//        let testUser2 = LazyUserCell(user: "TestUser2")
        let dataSource1 = CollectionCellViewModelDataSource(testUser1)
        let section2 = CollectionSectionViewModel(
            diffingKey: "default_section",
            cellViewModels: [],
            cellViewModelDataSource: dataSource1
        )
        let updatedModel = CollectionViewModel(
            sectionModels: [section2]
        )

        self.collectionViewDataSource.collectionViewModel = updatedModel

        XCTAssertEqual(self.mockCollectionView.callsToInsertItems.count, 1)
        XCTAssertEqual(self.mockCollectionView.callsToReloadData, 2)
    }
}

final class LazyTestUserCell: CollectionCellViewModel, DiffableViewModel {
    var accessibilityFormat: CellAccessibilityFormat = ""
    let registrationInfo = ViewRegistrationInfo(classType: UICollectionViewCell.self)

    let user: String
    private(set) var diffingKeyAccessed: Bool = false

    init(user: String) {
        self.user = user
    }

    func applyViewModelToCell(_ cell: UICollectionViewCell) {}

    func willDisplay(cell: UICollectionViewCell) {}

    var diffingKey: String {
        self.diffingKeyAccessed = true
        return self.user
    }
}
