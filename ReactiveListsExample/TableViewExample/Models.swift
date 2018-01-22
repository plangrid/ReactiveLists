//
//  Models.swift
//  ReactiveLists
//
//  Created by Benji Encz on 7/26/17.
//  Copyright © 2017 PlanGrid. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let uuid = UUID()
}

struct UserGroup {
    let name: String
    var users: [User]
}
