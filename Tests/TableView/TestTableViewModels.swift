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

struct TestCellViewModel: TableCellViewModel {
    let rowHeight: CGFloat = 42
    let editingStyle = UITableViewCellEditingStyle.delete
    let shouldHighlight = false
    let shouldIndentWhileEditing = false
    let accessibilityFormat: CellAccessibilityFormat = "access-%{section}.%{row}"
    let registrationInfo = ViewRegistrationInfo(classType: TestTableViewCell.self)

    let label: String
    var willBeginEditing: WillBeginEditingClosure?
    var didEndEditing: DidEndEditingClosure?
    var commitEditingStyle: CommitEditingStyleClosure?
    var didSelectClosure: DidSelectClosure?

    var diffingKey: DiffingKey {
        return self.label
    }

    init(label: String,
         willBeginEditing: WillBeginEditingClosure? = nil,
         didEndEditing: DidEndEditingClosure? = nil,
         commitEditingStyle: CommitEditingStyleClosure? = nil,
         didSelectClosure: DidSelectClosure? = nil
    ) {
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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

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

func generateTableCellViewModels(count: Int = 4) -> [TableCellViewModel] {
    var models = [TestCellViewModel]()
    for _ in 0..<count {
        models.append(TestCellViewModel(label: UUID().uuidString))
    }
    return models
}

func generateTestCellViewModel(_ label: String? = nil) -> TestCellViewModel {
    return TestCellViewModel(label: label ?? UUID().uuidString)
}

struct TestHeaderFooterViewModel: TableSectionHeaderFooterViewModel {
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
            registrationInfo: ViewRegistrationInfo(classType: viewKind == .header ? HeaderView.self : FooterView.self),
            kind: viewKind,
            accessibilityFormat: SupplementaryAccessibilityFormat("access_\(kindString)+%{section}")) // e.g. access_header+%{section}
    }

    func applyViewModelToView(_ view: UIView) {
        switch self.viewInfo!.kind {
        case .header:
            if let view = view as? HeaderView {
                view.label = self.title
            }
        case .footer:
            if let view = view as? FooterView {
                view.label = self.title
            }
        }
    }
}
