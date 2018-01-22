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

import Foundation
import ReactiveLists


func collectionViewModel(forState groups: [UserGroup], onDeleteClosure: @escaping (User) -> Void) -> FluxCollectionViewModel {
    let sections: [FluxCollectionViewModel.SectionModel] = groups.map { group in
        let cellViewModels = group.users.map { CollectionUserCell(user: $0, onDeleteClosure: onDeleteClosure) }
        return FluxCollectionViewModel.SectionModel(cellViewModels: cellViewModels, headerHeight: nil, footerHeight: nil)
    }
    return FluxCollectionViewModel(sectionModels: sections)
}
