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
            self.registerCellViewModels($0.cellViewModels)

            if let header = $0.headerViewModel {
                self.registerSupplementaryViewModel(header)
            }

            if let footer = $0.footerViewModel {
                self.registerSupplementaryViewModel(footer)
            }
        }
    }

    func configuredCell(for model: CollectionViewCellViewModel, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.dequeueReusableCellFor(identifier: model.registrationInfo.reuseIdentifier, indexPath: indexPath)
        model.applyViewModelToCell(cell)
        cell.accessibilityIdentifier = model.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        return cell
    }
}
