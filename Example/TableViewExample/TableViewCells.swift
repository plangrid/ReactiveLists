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

struct UserCell: TableViewCellViewModel, DiffableViewModel {
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
