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
    var groups: [ToolGroup] = [] {
        didSet {
            let model = CollectionViewController.viewModel(
                forState: groups,
                onDeleteClosure: { deletedTool in
                    // Iterate through the user groups and find the deleted user.
                    for (index, group) in self.groups.enumerated() {
                        self.groups[index].tools = group.tools.filter { $0.uuid != deletedTool.uuid }
                    }
            }
            )
            self.collectionViewDataSource?.collectionViewModel = model
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(
            UINib(nibName: "CollectionToolCell", bundle: nil),
            forCellWithReuseIdentifier: "CollectionToolCell"
        )

        self.collectionViewDataSource = CollectionViewDataSource(
            collectionView: self.collectionView!,
            automaticDiffingEnabled: true
        )

        self.groups = [
            ToolGroup(
                name: "Old Tools",
                tools: [Tool(type: .wrench), Tool(type: .hammer), Tool(type: .clamp), Tool(type: .nutBolt), Tool(type: .crane)]
            ),
            ToolGroup(
                name: "New Tool",
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

extension CollectionViewController {
    /// Pure function mapping new state to a new `CollectionViewModel`.  This is invoked each time the state updates
    /// in order for ReactiveLists to update the UI.
    static func viewModel(forState groups: [ToolGroup], onDeleteClosure: @escaping (Tool) -> Void) -> CollectionViewModel {
        let sections: [CollectionViewModel.SectionModel] = groups.map { group in
            let cellViewModels = group.tools.map { CollectionToolCellModel(tool: $0, onDeleteClosure: onDeleteClosure) }
            return CollectionViewModel.SectionModel(
                cellViewModels: cellViewModels,
                headerHeight: 44,
                footerHeight: 44,
                diffingKey: group.name
            )
        }
        return CollectionViewModel(sectionModels: sections)
    }
}
