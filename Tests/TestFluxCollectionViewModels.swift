//
//  TestFluxCollectionViewModels.swift
//  PlanGrid
//
//  Created by Kiefer Aguilar on 2/4/16.
//  Copyright © 2016 PlanGrid. All rights reserved.
//

import Foundation
@testable import ReactiveLists

struct TestCollectionCellViewModel: FluxCollectionViewCellViewModel {
    let label: String
    let didSelectClosure: DidSelectClosure?
    let didDeselectClosure: DidDeselectClosure?

    let cellIdentifier = "foo_identifier"
    let accessibilityFormat: CellAccessibilityFormat = "access-%{section}.%{row}"
    let shouldHighlight = false

    func applyViewModelToCell(_ cell: UICollectionViewCell) -> UICollectionViewCell {
        guard let testCell = cell as? TestFluxCollectionViewCell else { return cell }
        testCell.label = self.label
        return testCell
    }
}

struct TestCollectionViewSupplementaryViewModel: FluxCollectionViewSupplementaryViewModel {
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
            registrationMethod: .viewClass(viewKind == .header ? HeaderView.self : FooterView.self),
            reuseIdentifier: "reuse_\(kindString)+\(sectionLabel)", // e.g. reuse_header+A
            accessibilityFormat: SupplementaryAccessibilityFormat("access_\(kindString)+%{section}")) // e.g. access_header+%{section}
    }

    func applyViewModelToView(_ view: UICollectionReusableView) -> UICollectionReusableView {
        guard let testView = view as? TestFluxCollectionReusableView else { return view }
        testView.label = self.label
        return testView
    }
}

class TestFluxCollectionViewCell: UICollectionViewCell {
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

class TestFluxCollectionReusableView: UICollectionReusableView {
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

func generateRandomTestCollectionCellViewModel(_ label: String? = nil) -> TestCollectionCellViewModel {
    return TestCollectionCellViewModel(
        label: label ?? UUID().uuidString,
        didSelectClosure: nil,
        didDeselectClosure: nil)
}
