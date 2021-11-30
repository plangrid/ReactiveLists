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
    var callsToDeselect = 0
    var callsToInsertRowAtIndexPaths: [(indexPaths: [IndexPath], animation: UITableView.RowAnimation)] = []
    var callsToDeleteSections: [(sections: IndexSet, animation: UITableView.RowAnimation)] = []
    var callsToReloadData = 0
    var indexPathsForVisibleRowsOverride: [IndexPath]?

    /// Setup after init to avoid crashes in iOS 10
    private var _window: UIWindow?

    override var window: UIWindow? {
        return self._window
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self._window = UIWindow()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var indexPathsForVisibleRows: [IndexPath]? {
        if let indexPathsForVisibleRowsOverride = self.indexPathsForVisibleRowsOverride {
            return indexPathsForVisibleRowsOverride
        }
        return (0..<self.dataSource!.numberOfSections!(in: self)).flatMap { section -> [IndexPath] in
            (0..<self.dataSource!.tableView(self, numberOfRowsInSection: section)).map { IndexPath(row: $0, section: section) }
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

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        self.callsToInsertRowAtIndexPaths.append((indexPaths: indexPaths, animation: animation))
    }

    override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        self.callsToDeleteSections.append((sections: sections, animation: animation))
    }

    override func reloadData() {
        self.callsToReloadData += 1
    }

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }
}

extension TableViewDriver {
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

class MockCellViewModel: TableCellViewModel {
    var accessibilityFormat: CellAccessibilityFormat = "_"
    let registrationInfo = ViewRegistrationInfo(classType: UITableViewCell.self)
    func applyViewModelToCell(_ cell: UITableViewCell) { }
    func willDisplay(cell: UITableViewCell) { }

    var didSelect: DidSelectClosure?
    var didSelectCalled = false
    var willBeginEditing: WillBeginEditingClosure?
    var willBeginEditingCalled = false
    var didEndEditing: DidEndEditingClosure?
    var didEndEditingCalled = false
    var commitEditingStyle: CommitEditingStyleClosure?
    var commitEditingStyleCalled: UITableViewCell.EditingStyle?

    init() {
        self.didSelect = { [unowned self] in self.didSelectCalled = true }
        self.willBeginEditing = { [unowned self] in self.willBeginEditingCalled = true }
        self.didEndEditing = { [unowned self] in self.didEndEditingCalled = true }
        self.commitEditingStyle = { [unowned self] in self.commitEditingStyleCalled = $0 }
    }
}
