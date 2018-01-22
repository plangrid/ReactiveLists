//
//  Cells.swift
//  ReactiveLists
//
//  Created by Benji Encz on 7/26/17.
//  Copyright © 2017 PlanGrid. All rights reserved.
//

import Foundation
import ReactiveLists

struct UserCell: FluxTableViewCellViewModel, DiffableViewModel {
    var accessibilityFormat: CellAccessibilityFormat = ""
    let cellIdentifier = "UserCell"

    let commitEditingStyle: CommitEditingStyleClosure?
    let editingStyle: UITableViewCellEditingStyle = .delete

    let user: User

    init(user: User, onDeleteClosure: @escaping (User) -> Void) {
        self.user = user
        self.commitEditingStyle = { style in
            if style == .delete {
                onDeleteClosure(user)
            }
        }
    }

    func applyViewModelToCell(_ cell: UITableViewCell) -> UITableViewCell {
        cell.textLabel?.text = self.user.name

        return cell
    }

    var diffingKey: String {
        return self.user.uuid.uuidString
    }
}
