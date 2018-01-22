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
class CollectionViewController: UIViewController {

    lazy var collectionView: UICollectionView = {
        UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
    }()

    var collectionViewDataSource: FluxCollectionViewDataSource?
    var groups: [UserGroup] = [] {
        didSet {
            let model = collectionViewModel(
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

        self.title = "Collection View Example"

        self.collectionView.frame = self.view.frame
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.collectionView)

        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionUserCell")
        self.collectionViewDataSource = FluxCollectionViewDataSource(shouldDeselectUponSelection: true)
        self.collectionViewDataSource?.collectionView = self.collectionView

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Flip", style: .plain, target: self, action: #selector(self.swapSections)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(self.addUser)
        )

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

    @objc
    func addUser() {
        self.groups[0].users.append(User(name: "New User!"))
    }

    @objc
    func swapSections() {
        let group0 = self.groups[0]
        self.groups[0] = self.groups[1]
        self.groups[1] = group0
    }
}
