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
import UIKit

public struct SupplementaryViewInfo {

    public let registrationMethod: ViewRegistrationMethod

    public let reuseIdentifier: String

    public let kind: SupplementaryViewKind

    /// `TableViewDataSource` and `CollectionViewDataSource` will automatically apply
    /// an `accessibilityIdentifier` to the supplementary view based on this format.
    public let accessibilityFormat: SupplementaryAccessibilityFormat

    public init(registrationMethod: ViewRegistrationMethod,
                reuseIdentifier: String,
                kind: SupplementaryViewKind,
                accessibilityFormat: SupplementaryAccessibilityFormat) {
        self.registrationMethod = registrationMethod
        self.reuseIdentifier = reuseIdentifier
        self.kind = kind
        self.accessibilityFormat = accessibilityFormat
    }
}

public enum SupplementaryViewKind {
    case header
    case footer

    init?(collectionElementKindString: String) {
        switch collectionElementKindString {
        case UICollectionElementKindSectionHeader:
            self = .header
        case UICollectionElementKindSectionFooter:
            self = .footer
        default:
            return nil
        }
    }

    var collectionElementKind: String {
        switch self {
        case .header: return UICollectionElementKindSectionHeader
        case .footer: return UICollectionElementKindSectionFooter
        }
    }
}
