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
@testable import ReactiveLists

struct TestCellViewModel: TableViewCellViewModel {
    let rowHeight: CGFloat = 42
    let editingStyle = UITableViewCellEditingStyle.delete
    let shouldHighlight = false
    let shouldIndentWhileEditing = false
    let accessibilityFormat: CellAccessibilityFormat = "access-%{section}.%{row}"

    let registrationInfo: ViewRegistrationInfo
    let label: String
    var willBeginEditing: WillBeginEditingClosure?
    var didEndEditing: DidEndEditingClosure?
    var commitEditingStyle: CommitEditingStyleClosure?
    var didSelectClosure: DidSelectClosure?

    init(label: String,
         registrationInfo: ViewRegistrationInfo,
         willBeginEditing: WillBeginEditingClosure? = nil,
         didEndEditing: DidEndEditingClosure? = nil,
         commitEditingStyle: CommitEditingStyleClosure? = nil,
         didSelectClosure: DidSelectClosure? = nil
    ) {
        self.registrationInfo = registrationInfo
        self.label = label
        self.willBeginEditing = willBeginEditing
        self.didEndEditing = didEndEditing
        self.commitEditingStyle = commitEditingStyle
        self.didSelectClosure = didSelectClosure
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        guard let testCell = cell as? TestTableViewCell else { return }
        testCell.label = self.label
    }
}

class TestTableViewCell: UITableViewCell {
    var identifier: String?
    var label: String?

    init(identifier: String) {
        self.identifier = identifier
        super.init(style: .default, reuseIdentifier: identifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

func path(_ section: Int, _ row: Int = 0) -> IndexPath {
    return IndexPath(row: row, section: section)
}

func generateTestCellViewModel(_ label: String? = nil) -> TestCellViewModel {
    return TestCellViewModel(label: label ?? UUID().uuidString,
                             registrationInfo: ViewRegistrationInfo(classType: TestTableViewCell.self),
                             willBeginEditing: nil,
                             didEndEditing: nil,
                             commitEditingStyle: nil,
                             didSelectClosure: nil
    )
}

struct TestHeaderFooterViewModel: TableViewSectionHeaderFooterViewModel {
    let title: String?
    let height: CGFloat?
    let viewInfo: SupplementaryViewInfo?

    init(title: String?, height: CGFloat?, viewInfo: SupplementaryViewInfo? = nil) {
        self.title = title
        self.height = height
        self.viewInfo = viewInfo
    }

    init(height: CGFloat?, viewKind: SupplementaryViewKind = .header, label: String = "A") {
        let kindString = viewKind == .header ? "header" : "footer"

        self.title = "title_\(kindString)+\(label)" // e.g. title_header+3
        self.height = height

        self.viewInfo = SupplementaryViewInfo(
            registrationMethod: .fromClass(viewKind == .header ? HeaderView.self : FooterView.self),
            reuseIdentifier: "reuse_\(kindString)+\(label)", // e.g. reuse_header_3
            kind: viewKind,
            accessibilityFormat: SupplementaryAccessibilityFormat("access_\(kindString)+%{section}")) // e.g. access_header+%{section}
    }

    func applyViewModelToView(_ view: UIView) {
        guard let view = view as? TestTableViewSectionHeaderFooter else { return }
        view.label = self.title
    }
}

class TestTableViewSectionHeaderFooter: UITableViewHeaderFooterView {
    var identifier: String?
    var label: String?

    init(identifier: String) {
        self.identifier = identifier
        super.init(reuseIdentifier: identifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
