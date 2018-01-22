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
class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        UITableView()
    }()

    var tableViewDataSource: FluxTableViewDataSource?
    var groups: [UserGroup] = [] {
        didSet {
            self.tableViewDataSource?.tableViewModel.value = tableViewModel(
                forState: groups,
                onDeleteClosure: { deletedUser in
                    // Iterate through the user groups and find the deleted user.
                    for (index, group) in self.groups.enumerated() {
                        self.groups[index].users = group.users.filter { $0.uuid != deletedUser.uuid }
                    }
                }
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Reactive List Example"

        self.tableView.frame = self.view.frame
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.tableView)
        self.tableViewDataSource = FluxTableViewDataSource(automaticDiffEnabled: true)
        self.tableViewDataSource?.tableView = self.tableView
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")

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
