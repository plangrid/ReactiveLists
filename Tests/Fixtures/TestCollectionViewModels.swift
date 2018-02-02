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

struct TestCollectionCellViewModel: CollectionCellViewModel {
    let label: String
    let didSelect: DidSelectClosure?
    let didDeselect: DidDeselectClosure?

    let registrationInfo = ViewRegistrationInfo(classType: TestCollectionViewCell.self)
    let accessibilityFormat: CellAccessibilityFormat = "access-%{section}.%{row}"
    let shouldHighlight = false

    func applyViewModelToCell(_ cell: UICollectionViewCell) {
        guard let testCell = cell as? TestCollectionViewCell else { return }
        testCell.label = self.label
    }
}

struct TestCollectionViewSupplementaryViewModel: CollectionSupplementaryViewModel {
    let label: String?
    let height: CGFloat?
    let viewInfo: SupplementaryViewInfo?

    init(label: String?, height: CGFloat?, viewInfo: SupplementaryViewInfo? = nil) {
        self.label = label
        self.height = height
        self.viewInfo = viewInfo
    }

    init(height: CGFloat?, viewKind: SupplementaryViewKind = .header, sectionLabel: String) {
        let kindString = viewKind == .header ? "header" : "footer"
        self.label = "label_\(kindString)+\(sectionLabel)" // e.g. title_header+A
        self.height = height
        self.viewInfo = SupplementaryViewInfo(
            registrationInfo: ViewRegistrationInfo(classType: viewKind == .header ? HeaderView.self : FooterView.self),
            kind: viewKind,
            accessibilityFormat: SupplementaryAccessibilityFormat("access_\(kindString)+%{section}")) // e.g. access_header+%{section}
    }

    func applyViewModelToView(_ view: UICollectionReusableView) {
        guard let testView = view as? TestCollectionReusableView else { return }
        testView.label = self.label
    }
}

class TestCollectionViewCell: UICollectionViewCell {
    var identifier: String?
    var label: String?

    init(identifier: String) {
        self.identifier = identifier
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TestCollectionReusableView: UICollectionReusableView {
    var identifier: String?
    var label: String?

    init(identifier: String) {
        self.identifier = identifier
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

func generateTestCollectionCellViewModel(_ label: String? = nil) -> TestCollectionCellViewModel {
    return TestCollectionCellViewModel(
        label: label ?? UUID().uuidString,
        didSelect: nil,
        didDeselect: nil
    )
}
