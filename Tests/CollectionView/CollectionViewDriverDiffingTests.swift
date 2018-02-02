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

final class CollectionViewDriverDiffingTests: XCTestCase {

    var collectionViewDataSource: CollectionViewDriver!
    var mockCollectionView: TestCollectionView!

    override func setUp() {
        super.setUp()
        self.mockCollectionView = TestCollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        self.collectionViewDataSource = CollectionViewDriver(
            collectionView: self.mockCollectionView,
            automaticDiffingEnabled: true
        )
    }

    /// Tests that changes to individual rows result in the correct calls to update the
    /// collection view.
    ///
    /// - Note: We're only testing one type of row update since this is sufficient to test the
    ///   communication between the diffing lib and the collection view. The diffing lib itself has
    ///   extensive tests for the various diffing scenarios.
    func testChangingRows() {
        let initialModel = CollectionViewModel(
            sectionModels: [
                CollectionSectionViewModel(
                    cellViewModels: [],
                    headerHeight: 44,
                    footerHeight: 44,
                    diffingKey: "1"
                )
            ]
        )

        self.collectionViewDataSource.collectionViewModel = initialModel

        let updatedModel = CollectionViewModel(
            sectionModels: [
                CollectionSectionViewModel(
                    cellViewModels: [CollectionUserCellModel(user: User(name: "Mona"))],
                    headerHeight: 44,
                    footerHeight: 44,
                    diffingKey: "1"
                )
            ]
        )

        self.collectionViewDataSource.collectionViewModel = updatedModel

        XCTAssertEqual(self.mockCollectionView.callsToInsertItems.count, 1)
        XCTAssertEqual(
            self.mockCollectionView.callsToInsertItems[0],
            [IndexPath(row: 0, section: 0)]
        )
    }

    /// Tests that changes to individual sections result in the correct calls to update the
    /// collection view.
    ///
    /// - Note: We're only testing one type of section update since this is sufficient to test the
    ///   communication between the diffing lib and the collection view. The diffing lib itself has
    ///   extensive tests for the various diffing scenarios.
    func testChangingSections() {
        let initialModel = CollectionViewModel(
            sectionModels: [
                CollectionSectionViewModel(
                    cellViewModels: [],
                    headerHeight: 44,
                    footerHeight: 44,
                    diffingKey: "1"
                ),
                CollectionSectionViewModel(
                    cellViewModels: [],
                    headerHeight: 44,
                    footerHeight: 44,
                    diffingKey: "2"
                )
            ]
        )

        self.collectionViewDataSource.collectionViewModel = initialModel

        let updatedModel = CollectionViewModel(
            sectionModels: [
                CollectionSectionViewModel(
                    cellViewModels: [],
                    headerHeight: 44,
                    footerHeight: 44,
                    diffingKey: "2"
                )
            ]
        )

        self.collectionViewDataSource.collectionViewModel = updatedModel

        XCTAssertEqual(self.mockCollectionView.callsToDeleteSections.count, 1)
        XCTAssertEqual(
            self.mockCollectionView.callsToDeleteSections[0],
            IndexSet(integer: 0)
        )
    }
}

struct CollectionUserCellModel: CollectionCellViewModel, DiffableViewModel {

    var accessibilityFormat: CellAccessibilityFormat = "CollectionUserCell"
    var registrationInfo = ViewRegistrationInfo(classType: TestCollectionViewCell.self)
    let editingStyle: UITableViewCellEditingStyle = .delete

    let user: User

    init(user: User) {
        self.user = user
    }

    func applyViewModelToCell(_ cell: UICollectionViewCell) { }

    var diffingKey: String {
        return self.user.uuid.uuidString
    }
}

struct User {
    let name: String
    let uuid = UUID()
}

struct UserGroup {
    let name: String
    var users: [User]
}
