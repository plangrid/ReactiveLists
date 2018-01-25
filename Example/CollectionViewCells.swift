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

final class CollectionToolCell: UICollectionViewCell {
    @IBOutlet weak var toolNameLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
}

final class CollectionToolCellModel: CollectionViewCellViewModel, DiffableViewModel {

    var accessibilityFormat: CellAccessibilityFormat = "CollectionToolCell"
    let cellIdentifier = "CollectionToolCell"

    let commitEditingStyle: CommitEditingStyleClosure?
    let editingStyle: UITableViewCellEditingStyle = .delete

    let tool: Tool
    let onDeleteClosure: (Tool) -> Void

    init(tool: Tool, onDeleteClosure: @escaping (Tool) -> Void) {
        self.tool = tool
        self.onDeleteClosure = onDeleteClosure
        self.commitEditingStyle = { style in
            if style == .delete {
                onDeleteClosure(tool)
            }
        }
    }

    @objc
    func deleteTapped() {
        self.onDeleteClosure(self.tool)
    }

    func applyViewModelToCell(_ cell: UICollectionViewCell) {
        guard let collectionToolCell = cell as? CollectionToolCell else { return }
        collectionToolCell.toolNameLabel.text = self.tool.type.name
        collectionToolCell.emojiLabel.text = self.tool.type.emoji
        collectionToolCell.closeButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    var diffingKey: String {
        return self.tool.uuid.uuidString
    }
}

final class CollectionViewHeaderView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
}

struct CollectionViewHeaderModel: CollectionViewSupplementaryViewModel {
    var title: String?
    var height: CGFloat?
    var viewInfo: SupplementaryViewInfo?

    init(title: String?, height: CGFloat?, viewInfo: SupplementaryViewInfo? = nil) {
        self.title = title
        self.height = height
        self.viewInfo = viewInfo
    }

    func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView {
        guard let collectionHeaderView = view as? CollectionViewHeaderView else { return view }
        collectionHeaderView.headerLabel.text = self.title
        return collectionHeaderView
    }
}
