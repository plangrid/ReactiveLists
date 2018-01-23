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

import UIKit
@testable import ReactiveLists

typealias _RegisterClassCallInfo = (viewClass: AnyClass?, viewKind: SupplementaryViewKind?, reuseIdentifier: String)
class TestCollectionView: UICollectionView {

    var callsToRegisterClass: [_RegisterClassCallInfo?] = []
    var callsToDeselect: Int = 0

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
    }

    override func deselectItem(at indexPath: IndexPath, animated: Bool) {
        self.callsToDeselect += 1
    }
}
