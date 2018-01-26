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

    func configuredCell(for model: TableViewCellViewModel, at indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: model.registrationInfo.reuseIdentifier,
                                            for: indexPath)
        model.applyViewModelToCell(cell)
        cell.accessibilityIdentifier = model.accessibilityFormat.accessibilityIdentifierForIndexPath(indexPath)
        return cell
    }

    func registerViews(for model: TableViewModel) {
        model.sectionModels.forEach {
            self._registerCells($0.cellViewModels)
            self._registerHeaderFooterViewModel($0.headerViewModel)
            self._registerHeaderFooterViewModel($0.footerViewModel)
        }
    }

    private func _registerCells(_ cellViewModels: [TableViewCellViewModel]) {
        cellViewModels.forEach {
            self._registerCellViewModel($0)
        }
    }

    private func _registerCellViewModel(_ viewModel: TableViewCellViewModel) {
        let registrationInfo = viewModel.registrationInfo
        let identifier = registrationInfo.reuseIdentifier
        let method = registrationInfo.registrationMethod

        switch method {
        case let .fromClass(classType):
            self.register(classType, forCellReuseIdentifier: identifier)
        case .fromNib:
            self.register(method.nib, forCellReuseIdentifier: identifier)
        }
    }

    private func _registerHeaderFooterViewModel(_ viewModel: TableViewSectionHeaderFooterViewModel?) {
        guard let viewInfo = viewModel?.viewInfo else { return }

        let identifier = viewInfo.reuseIdentifier
        let method = viewInfo.registrationMethod

        switch method {
        case .fromNib:
            self.register(method.nib, forHeaderFooterViewReuseIdentifier: identifier)
        case let .fromClass(classType):
            self.register(classType, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
}
