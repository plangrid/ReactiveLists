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

func tableViewModel(forState groups: [UserGroup], onDeleteClosure: @escaping (User) -> Void) -> FluxTableViewModel {
    let sections = groups.map { group in
        FluxTableViewModel.SectionModel(
            headerTitle: group.name,
            headerHeight: 20,
            cellViewModels: group.users.map { UserCell(user: $0, onDeleteClosure: onDeleteClosure) },
            diffingKey: group.name
        )
    }

    return FluxTableViewModel(sectionModels: sections)
}
