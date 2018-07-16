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
import UIKit

typealias _RegisterClassCallInfo = (viewClass: AnyClass?, viewKind: SupplementaryViewKind?, reuseIdentifier: String)
class TestCollectionView: UICollectionView {

    var callsToRegisterClass: [_RegisterClassCallInfo?] = []
    var callsToDeselect = 0

    var callsToReloadData = 0

    var callsToInsertItems = [[IndexPath]]()
    var callsToDeleteSections = [IndexSet]()

    override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return TestCollectionViewCell(identifier: identifier)
    }

    override func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionReusableView {
        return TestCollectionReusableView(identifier: identifier)
    }

    override func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        if let viewClass = viewClass {
            self.callsToRegisterClass.append((viewClass, SupplementaryViewKind(collectionElementKindString: elementKind), identifier))
        } else {
            self.callsToRegisterClass.append(nil)
        }
        super.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
    }

    override func deselectItem(at indexPath: IndexPath, animated: Bool) {
        super.deselectItem(at: indexPath, animated: animated)
        self.callsToDeselect += 1
    }

    override func insertItems(at indexPaths: [IndexPath]) {
        super.insertItems(at: indexPaths)
        self.callsToInsertItems.append(indexPaths)
    }

    override func deleteSections(_ sections: IndexSet) {
        super.deleteSections(sections)
        self.callsToDeleteSections.append(sections)
    }

    override func reloadData() {
        super.reloadData()
        self.callsToReloadData += 1
    }
}
