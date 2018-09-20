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

struct ToolTableCellModel: TableCellViewModel, DiffableViewModel {
    let registrationInfo = ViewRegistrationInfo(classType: ToolTableViewCell.self)

    let commitEditingStyle: CommitEditingStyleClosure?
    let editingStyle: UITableViewCell.EditingStyle = .delete
    let accessibilityFormat: CellAccessibilityFormat = ""

    let tool: Tool

    init(tool: Tool, onDeleteClosure: @escaping (Tool) -> Void) {
        self.tool = tool
        self.commitEditingStyle = { style in
            if style == .delete {
                onDeleteClosure(tool)
            }
        }
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "\(self.tool.type.emoji) \(self.tool.type.name)"
    }

    var diffingKey: String {
        return self.tool.uuid.uuidString
    }
}
