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
            if let header = $0.headerViewModel {
                self._registerSupplementaryViewModel(header)
            }

            if let footer = $0.footerViewModel {
                self._registerSupplementaryViewModel(footer)
            }
        }
    }

    private func _registerSupplementaryViewModel(_ viewModel: CollectionViewSupplementaryViewModel) {
        if let viewInfo = viewModel.viewInfo {
            switch viewInfo.registrationMethod {
            case let .nib(name, bundle):
                self.register(UINib(nibName: name, bundle: bundle),
                              forSupplementaryViewOfKind: viewInfo.kind.collectionElementKind,
                              withReuseIdentifier: viewInfo.reuseIdentifier)
            case let .viewClass(viewClass):
                self.register(viewClass,
                              forSupplementaryViewOfKind: viewInfo.kind.collectionElementKind,
                              withReuseIdentifier: viewInfo.reuseIdentifier)
            }
        }
    }
}
