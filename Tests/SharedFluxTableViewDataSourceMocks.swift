//
//  SharedFluxTableViewDataSourceMocks.swift
//  PlanGrid
//
//  Created by Kiefer Aguilar on 3/3/16.
//  Copyright © 2016 PlanGrid. All rights reserved.
//

@testable import ReactiveLists

class HeaderView: UITableViewHeaderFooterView {}
class FooterView: UITableViewHeaderFooterView {}

class TestFluxTableView: UITableView {
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
        return TestFluxTableViewCell(identifier: identifier)
    }

    override func dequeueReusableHeaderFooterView(withIdentifier identifier: String) -> UITableViewHeaderFooterView? {
        return TestFluxTableViewSectionHeaderFooter(identifier: identifier)
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

class TestFluxTableViewDataSource: FluxTableViewDataSource {
    var label: String?
}

extension FluxTableViewDataSource {
    func _getCell(_ path: IndexPath) -> TestFluxTableViewCell? {
        let tableView = self._tableView
        guard let cell = self.tableView(tableView, cellForRowAt: path) as? TestFluxTableViewCell else { return nil }
        return cell
    }

    func _getHeader(_ section: Int) -> TestFluxTableViewSectionHeaderFooter? {
        let tableView = self._tableView
        guard let cell = self.tableView(tableView, viewForHeaderInSection: section) as? TestFluxTableViewSectionHeaderFooter else { return nil }
        return cell
    }

    func _getFooter(_ section: Int) -> TestFluxTableViewSectionHeaderFooter? {
        let tableView = self._tableView
        guard let cell = self.tableView(tableView, viewForFooterInSection: section) as? TestFluxTableViewSectionHeaderFooter else { return nil }
        return cell
    }
}
