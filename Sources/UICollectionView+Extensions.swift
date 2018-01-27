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

extension UICollectionView {

    func registerViews(for model: CollectionViewModel) {
        model.sectionModels.forEach {
            // TODO: collection cells

            if let header = $0.headerViewModel {
                self.registerSupplementaryViewModel(header)
            }

            if let footer = $0.footerViewModel {
                self.registerSupplementaryViewModel(footer)
            }
        }
    }
}
