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

final class CollectionViewController: UICollectionViewController {

    var collectionViewDataSource: CollectionViewDataSource?
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
            self.collectionViewDataSource?.collectionViewModel = model
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(
            UINib(nibName: "CollectionUserCell", bundle: nil),
            forCellWithReuseIdentifier: "CollectionUserCell"
        )

        self.collectionViewDataSource = CollectionViewDataSource(collectionView: self.collectionView!)

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

    @IBAction func swapSections(_ sender: Any) {
        let group0 = self.groups[0]
        self.groups[0] = self.groups[1]
        self.groups[1] = group0
    }

    @IBAction func addUser(_ sender: Any) {
        self.groups[0].users.append(User(name: "New User!"))
    }
}

// MARK: View Model Provider

extension CollectionViewController {
    /// Pure function mapping new state to a new `CollectionViewModel`.  This is invoked each time the state updates
    /// in order for ReactiveLists to update the UI.
    static func viewModel(forState groups: [UserGroup], onDeleteClosure: @escaping (User) -> Void) -> CollectionViewModel {
        let sections: [CollectionViewModel.SectionModel] = groups.map { group in
            let cellViewModels = group.users.map { CollectionUserCellModel(user: $0, onDeleteClosure: onDeleteClosure) }
            return CollectionViewModel.SectionModel(cellViewModels: cellViewModels, headerHeight: 44, footerHeight: 44)
        }
        return CollectionViewModel(sectionModels: sections)
    }
}
