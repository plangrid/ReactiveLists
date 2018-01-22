//
//  ViewModelProvider.swift
//  ReactiveLists
//
//  Created by Benji Encz on 7/26/17.
//  Copyright © 2017 PlanGrid. All rights reserved.
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
