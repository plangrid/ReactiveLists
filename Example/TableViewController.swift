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

final class TableViewController: UITableViewController {

    var tableViewDriver: TableViewDriver?
    var groups: [ToolGroup] = [] {
        didSet {
            self.tableViewDriver?.tableViewModel = TableViewController.viewModel(
                forState: groups,
                onDeleteClosure: { deletedTool in
                    // Iterate through the user groups and find the deleted user.
                    for (index, group) in self.groups.enumerated() {
                        self.groups[index].tools = group.tools.filter { $0.uuid != deletedTool.uuid }
                    }
                }
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewDriver = TableViewDriver(tableView: self.tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableUserCell")

        self.groups = [
            ToolGroup(
                name: "OLD TOOLS",
                tools: [Tool(type: .wrench), Tool(type: .hammer), Tool(type: .clamp), Tool(type: .nutBolt), Tool(type: .crane)]
            ),
            ToolGroup(
                name: "NEW TOOLS",
                tools: [Tool(type: .wrench), Tool(type: .hammer), Tool(type: .clamp), Tool(type: .nutBolt), Tool(type: .crane)]
            ),
        ]
    }

    @IBAction func swapSections(_ sender: Any) {
        let group0 = self.groups[0]
        self.groups[0] = self.groups[1]
        self.groups[1] = group0
    }

    @IBAction func addTool(_ sender: Any) {
        self.groups[0].tools.append(Tool.randomTool())
    }
}

// MARK: View Model Provider

extension TableViewController {

    /// Pure function mapping new state to a new `TableViewModel`.  This is invoked each time the state updates
    /// in order for ReactiveLists to update the UI.
    static func viewModel(forState groups: [ToolGroup], onDeleteClosure: @escaping (Tool) -> Void) -> TableViewModel {
        let sections: [TableViewModel.SectionModel] = groups.map { group in
            let cellViewModels = group.tools.map { ToolTableCellModel(tool: $0, onDeleteClosure: onDeleteClosure) }
            return TableViewModel.SectionModel(
                headerTitle: group.name,
                headerHeight: 44,
                cellViewModels: cellViewModels,
                diffingKey: group.name
            )
        }
        return TableViewModel(sectionModels: sections)
    }
}
