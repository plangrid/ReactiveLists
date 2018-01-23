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

@testable import ReactiveLists

class HeaderView: UITableViewHeaderFooterView {}
class FooterView: UITableViewHeaderFooterView {}

class TestTableView: UITableView {
    var callsToRegisterClass: [(viewClass: AnyClass?, identifier: String)] = []
    var callsToDeselect: Int = 0
    var callsToInsertRowAtIndexPaths: [(indexPaths: [IndexPath], animation: UITableViewRowAnimation)] = []
    var callsToDeleteSections: [(sections: IndexSet, animation: UITableViewRowAnimation)] = []

    override var indexPathsForVisibleRows: [IndexPath]? {
        return (0..<self.numberOfSections).flatMap { (section) -> [IndexPath] in
            (0..<self.numberOfRows(inSection: section)).map { IndexPath(row: $0, section: section) }
        }
    }

    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAt: indexPath)
    }

    override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return TestTableViewCell(identifier: identifier)
    }

    override func dequeueReusableHeaderFooterView(withIdentifier identifier: String) -> UITableViewHeaderFooterView? {
        return TestTableViewSectionHeaderFooter(identifier: identifier)
    }

    override func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        self.callsToRegisterClass.append((aClass, identifier))
    }

    override func deselectRow(at indexPath: IndexPath, animated: Bool) {
        self.callsToDeselect += 1
    }

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.insertRows(at: indexPaths, with: animation)
        self.callsToInsertRowAtIndexPaths.append((indexPaths: indexPaths, animation: animation))
    }

    override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        super.deleteSections(sections, with: animation)
        self.callsToDeleteSections.append((sections: sections, animation: animation))
    }
}

extension TableViewDataSource {
    func _getCell(_ path: IndexPath) -> TestTableViewCell? {
        guard let cell = self.tableView(self.tableView, cellForRowAt: path) as? TestTableViewCell else { return nil }
        return cell
    }

    func _getHeader(_ section: Int) -> TestTableViewSectionHeaderFooter? {
        guard let cell = self.tableView(self.tableView, viewForHeaderInSection: section) as? TestTableViewSectionHeaderFooter else { return nil }
        return cell
    }

    func _getFooter(_ section: Int) -> TestTableViewSectionHeaderFooter? {
        guard let cell = self.tableView(self.tableView, viewForFooterInSection: section) as? TestTableViewSectionHeaderFooter else { return nil }
        return cell
    }
}

class MockCellViewModel: TableViewCellViewModel {
    var accessibilityFormat: CellAccessibilityFormat = "_"
    var cellIdentifier = "_"
    func applyViewModelToCell(_ cell: UITableViewCell) -> UITableViewCell { return cell }

    var didSelectClosure: DidSelectClosure?
    var didSelectCalled = false
    var willBeginEditing: WillBeginEditingClosure?
    var willBeginEditingCalled = false
    var didEndEditing: DidEndEditingClosure?
    var didEndEditingCalled = false
    var commitEditingStyle: CommitEditingStyleClosure?
    var commitEditingStyleCalled: UITableViewCellEditingStyle?

    init() {
        self.didSelectClosure = { [unowned self] in self.didSelectCalled = true }
        self.willBeginEditing = { [unowned self] in self.willBeginEditingCalled = true }
        self.didEndEditing = { [unowned self] in self.didEndEditingCalled = true }
        self.commitEditingStyle = { [unowned self] in self.commitEditingStyleCalled = $0 }
    }
}
