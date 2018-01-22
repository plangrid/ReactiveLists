//
//  TestFluxViewModels.swift
//  PlanGrid
//
//  Created by Kiefer Aguilar on 1/27/16.
//  Copyright © 2016 PlanGrid. All rights reserved.
//

import Foundation
@testable import ReactiveLists

struct TestCellViewModel: FluxTableViewCellViewModel {
    let rowHeight: CGFloat = 42
    let editingStyle = UITableViewCellEditingStyle.delete
    let shouldHighlight = false
    let shouldIndentWhileEditing = false
    let accessibilityFormat: CellAccessibilityFormat = "access-%{section}.%{row}"

    let cellIdentifier: String
    let label: String
    let willBeginEditing: WillBeginEditingClosure?
    let didEndEditing: DidEndEditingClosure?
    let commitEditingStyle: CommitEditingStyleClosure?
    let didSelectClosure: DidSelectClosure?

    init(label: String,
         cellIdentifier: String? = nil,
         willBeginEditing: WillBeginEditingClosure? = nil,
         didEndEditing: DidEndEditingClosure? = nil,
         commitEditingStyle: CommitEditingStyleClosure? = nil,
         didSelectClosure: DidSelectClosure? = nil) {
        self.cellIdentifier = cellIdentifier ?? label
        self.label = label
        self.willBeginEditing = willBeginEditing
        self.didEndEditing = didEndEditing
        self.commitEditingStyle = commitEditingStyle
        self.didSelectClosure = didSelectClosure
    }

    func applyViewModelToCell(_ cell: UITableViewCell) -> UITableViewCell {
        guard let testCell = cell as? TestFluxTableViewCell else { return cell }
        testCell.label = self.label
        return testCell
    }
}

class TestFluxTableViewCell: UITableViewCell {
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

func generateRandomTestCellViewModel(_ label: String? = nil) -> TestCellViewModel {
    return TestCellViewModel(label: label ?? UUID().uuidString,
                             willBeginEditing: nil,
                             didEndEditing: nil,
                             commitEditingStyle: nil,
                             didSelectClosure: nil
    )
}

struct TestHeaderFooterViewModel: FluxTableViewSectionHeaderFooterViewModel {
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
            registrationMethod: .viewClass(viewKind == .header ? HeaderView.self : FooterView.self),
            reuseIdentifier: "reuse_\(kindString)+\(label)", // e.g. reuse_header_3
            accessibilityFormat: SupplementaryAccessibilityFormat("access_\(kindString)+%{section}")) // e.g. access_header+%{section}
    }

    func applyViewModelToView(_ view: UIView) {
        guard let view = view as? TestFluxTableViewSectionHeaderFooter else { return }
        view.label = self.title
    }
}

class TestFluxTableViewSectionHeaderFooter: UITableViewHeaderFooterView {
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
