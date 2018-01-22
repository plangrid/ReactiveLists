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

import ReactiveLists
import UIKit

@objc
class CollectionViewController: UICollectionViewController {

    var collectionViewDataSource: FluxCollectionViewDataSource?
    var groups: [UserGroup] = [] {
        didSet {
            let model = CollectionViewController.viewModel(
                forState: groups,
                onDeleteClosure: { deletedUser in
                    // Iterate through the user groups and find the deleted user.
                    for (index, group) in self.groups.enumerated() {
                        self.groups[index].users = group.users.filter { $0.uuid != deletedUser.uuid }
                    }
            }
            )
            self.collectionViewDataSource?.collectionViewModel.value = model
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionUserCell")
        self.collectionViewDataSource = FluxCollectionViewDataSource()
        self.collectionViewDataSource?.collectionView = self.collectionView

        self.groups = [
            UserGroup(
                name: "Premium",
                users: [User(name: "Premium1"), User(name: "Premium2")]
            ),
            UserGroup(
                name: "Regular",
                users: [User(name: "Regular1"), User(name: "Regular2")]
            ),
        ]
    }
}
