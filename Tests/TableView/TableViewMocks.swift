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

import DifferenceKit
@testable import ReactiveLists

final class HeaderView: UITableViewHeaderFooterView {
    var identifier: String?
    var label: String?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.identifier = reuseIdentifier
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FooterView: UITableViewHeaderFooterView {
    var identifier: String?
    var label: String?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.identifier = reuseIdentifier
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TestTableView {
    var callsToRegisterClass: [(viewClass: AnyClass?, identifier: String)] = []
    var callsToReloadData = 0
    var callsToReloadViaDiff: [Changeset<[TableSectionViewModel]>] = []

    weak var dataSource: UITableViewDataSource?
    weak var delegate: UITableViewDelegate?
}

extension TestTableView: TableView {

    private var testTableView: UITableView {
        return (self.dataSource as? TableViewDriver)?.testTableView ?? UITableView()
    }

    func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView?(self.testTableView, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    }

    func footerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView?(self.testTableView, viewForFooterInSection: section) as? UITableViewHeaderFooterView
    }

    func beginUpdates() {}
    func endUpdates() {}

    var indexPathsForVisibleRows: [IndexPath]? {
        let numberOfSections = self.dataSource?.numberOfSections?(in: self.testTableView) ?? 0
        return (0..<numberOfSections).flatMap { (section) -> [IndexPath] in
            let numberOfRows = self.dataSource?.tableView(self.testTableView, numberOfRowsInSection: section) ?? 0
            return (0..<numberOfRows).map { IndexPath(row: $0, section: section) }
        }
    }

    func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self.testTableView, cellForRowAt: indexPath)
    }

    func reloadData() {
        self.callsToReloadData += 1
    }

    //swiftlint:disable:next function_parameter_count
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadSectionsAnimation: @autoclosure () -> UITableViewRowAnimation,
        deleteRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        insertRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        reloadRowsAnimation: @autoclosure () -> UITableViewRowAnimation,
        interrupt: ((Changeset<C>) -> Bool)?,
        setData: (C) -> Void
    ) where C: Collection {
        if let stagedChangeset = stagedChangeset as? StagedChangeset<[TableSectionViewModel]> {
            var fullChangeset = Changeset<[TableSectionViewModel]>(data: [])

            // combine the staged changesets into one for easy inspection in tests
            for changeset in stagedChangeset {
                fullChangeset.data += changeset.data
                fullChangeset.sectionDeleted += changeset.sectionDeleted
                fullChangeset.sectionInserted += changeset.sectionInserted
                fullChangeset.sectionUpdated += changeset.sectionUpdated
                fullChangeset.sectionMoved += changeset.sectionMoved
                fullChangeset.elementDeleted += changeset.elementDeleted
                fullChangeset.elementInserted += changeset.elementInserted
                fullChangeset.elementUpdated += changeset.elementUpdated
                fullChangeset.elementMoved += changeset.elementMoved
            }

            self.callsToReloadViaDiff.append(fullChangeset)
        }
    }
}

extension TestTableView: CellContainerViewProtocol {

    typealias CellType = TestTableViewCell
    typealias SupplementaryType = UITableViewHeaderFooterView

    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> TestTableViewCell {
        return TestTableViewCell(identifier: identifier)
    }

    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> UITableViewHeaderFooterView? {
        return nil
    }

    func registerCellClass(_ cellClass: AnyClass?, identifier: String) {
        self.callsToRegisterClass.append((viewClass: cellClass, identifier: identifier))
    }

    func registerCellNib(_ cellNib: UINib?, identifier: String) {}

    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String) {
        self.callsToRegisterClass.append((viewClass: supplementaryClass, identifier: identifier))
    }

    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String) {}
}

extension TableViewDriver {
    func _getCell(_ path: IndexPath) -> TestTableViewCell? {
        return self.tableView.dataSource?.tableView(self.testTableView, cellForRowAt: path) as? TestTableViewCell
    }

    func _getHeader(_ section: Int) -> HeaderView? {
        return self.tableView.delegate?.tableView?(self.testTableView, viewForHeaderInSection: section) as?
            HeaderView
    }

    func _getFooter(_ section: Int) -> FooterView? {
        return self.tableView.delegate?.tableView?(self.testTableView, viewForFooterInSection: section) as? FooterView
    }
}

extension TableViewDriver {
    convenience init(
        tableView: TestTableView,
        tableViewModel: TableViewModel? = nil,
        shouldDeselectUponSelection: Bool = true,
        automaticDiffingEnabled: Bool = true
    ) {
        self.init(
            tableView: tableView,
            registerViews: tableView.registerViews(for:),
            tableViewModel: tableViewModel,
            shouldDeselectUponSelection: shouldDeselectUponSelection,
            automaticDiffingEnabled: automaticDiffingEnabled
        )
    }

    var testTableView: UITableView {
        let tableView = UITableView()
        if let tableViewModel = self.tableViewModel {
            tableView.registerViews(for: tableViewModel)
        }
        return tableView
    }
}

class MockCellViewModel: TableCellViewModel {
    var accessibilityFormat: CellAccessibilityFormat = "_"
    let registrationInfo = ViewRegistrationInfo(classType: UITableViewCell.self)
    func applyViewModelToCell(_ cell: UITableViewCell) { }

    var didSelect: DidSelectClosure?
    var didSelectCalled = false
    var willBeginEditing: WillBeginEditingClosure?
    var willBeginEditingCalled = false
    var didEndEditing: DidEndEditingClosure?
    var didEndEditingCalled = false
    var commitEditingStyle: CommitEditingStyleClosure?
    var commitEditingStyleCalled: UITableViewCellEditingStyle?

    init() {
        self.didSelect = { [unowned self] in self.didSelectCalled = true }
        self.willBeginEditing = { [unowned self] in self.willBeginEditingCalled = true }
        self.didEndEditing = { [unowned self] in self.didEndEditingCalled = true }
        self.commitEditingStyle = { [unowned self] in self.commitEditingStyleCalled = $0 }
    }
}

final class SelectionTestTableView: UITableView {
    var callsToDeselect = 0

    public override func deselectRow(at indexPath: IndexPath, animated: Bool) {
        self.callsToDeselect += 1
    }
}
