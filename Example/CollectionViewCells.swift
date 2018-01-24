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
import UIKit

final class CollectionUserCell: UICollectionViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
}

struct CollectionUserCellModel: CollectionViewCellViewModel, DiffableViewModel {

    var accessibilityFormat: CellAccessibilityFormat = "CollectionUserCell"
    let cellIdentifier = "CollectionUserCell"

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

    func applyViewModelToCell(_ cell: UICollectionViewCell) -> UICollectionViewCell {
        guard let collectionUserCell = cell as? CollectionUserCell else { return cell }
        collectionUserCell.usernameLabel.text = self.user.name
        return collectionUserCell
    }

    var diffingKey: String {
        return self.user.uuid.uuidString
    }
}
