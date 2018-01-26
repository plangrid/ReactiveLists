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

extension UITableView {

    func registerViews(for model: TableViewModel) {
        model.sectionModels.forEach {
            if let header = $0.headerViewModel {
                self._registerHeaderFooterViewModel(header)
            }

            if let footer = $0.footerViewModel {
                self._registerHeaderFooterViewModel(footer)
            }
        }
    }

    private func _registerHeaderFooterViewModel(_ viewModel: TableViewSectionHeaderFooterViewModel) {
        if let viewInfo = viewModel.viewInfo {
            switch viewInfo.registrationMethod {
            case let .nib(name, bundle):
                self.register(UINib(nibName: name, bundle: bundle),
                              forHeaderFooterViewReuseIdentifier: viewInfo.reuseIdentifier)
            case let .viewClass(viewClass):
                self.register(viewClass,
                              forHeaderFooterViewReuseIdentifier: viewInfo.reuseIdentifier)
            }
        }
    }
}
