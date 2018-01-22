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
    /// The method for registering the supplementary view
    public enum RegistrationMethod: Equatable {
        /// Class-based views
        case viewClass(AnyClass)
        /// Nib-based views
        case nib(name: String, bundle: Bundle?)

        public static func == (lhs: RegistrationMethod, rhs: RegistrationMethod) -> Bool {
            switch (lhs, rhs) {
            case let (.viewClass(lhsClass), .viewClass(rhsClass)):
                return lhsClass == rhsClass
            case let (.nib(lhsName, lhsBundle), .nib(rhsName, rhsBundle)):
                return lhsName == rhsName && lhsBundle == rhsBundle
            default:
                return false
            }
        }
    }

    let registrationMethod: RegistrationMethod
    let reuseIdentifier: String
    /// `FluxTableViewDataSource` and `FluxCollectionViewDataSource` will automatically apply an `accessibilityIdentifier` to the supplementary view based on this format
    let accessibilityFormat: SupplementaryAccessibilityFormat

    public init(
        registrationMethod: RegistrationMethod,
        reuseIdentifier: String,
        accessibilityFormat: SupplementaryAccessibilityFormat
    ) {
        self.registrationMethod = registrationMethod
        self.reuseIdentifier = reuseIdentifier
        self.accessibilityFormat = accessibilityFormat
    }
}

public enum SupplementaryViewKind {
    case header
    case footer

    /// Initialize with `UICollectionElementKindSectionHeader` or `UICollectionElementKindSectionFooter`
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
}
