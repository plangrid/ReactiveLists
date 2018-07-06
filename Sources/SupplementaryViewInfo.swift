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

/// Metadata thats required for setting up a supplementary view.
public struct SupplementaryViewInfo: Equatable {

    /// The registration info for the supplementary view.
    public let registrationInfo: ViewRegistrationInfo

    /// The kind of supplementary view (e.g. `header` or `footer`)
    public let kind: SupplementaryViewKind

    /// `TableViewDataSource` and `CollectionViewDataSource` will automatically apply
    /// an `accessibilityIdentifier` to the supplementary view based on this format.
    public let accessibilityFormat: SupplementaryAccessibilityFormat

    /// Initializes the metadata for a supplementary view.
    ///
    /// - Parameters:
    ///   - registrationInfo: The registration info for the view.
    ///   - kind: The kind of supplementary view (e.g. `header` or `footer`)
    ///   - accessibilityFormat: A format string that generates an accessibility identifier for
    ///                          the view that will be mapped to this view model.
    public init(
        registrationInfo: ViewRegistrationInfo,
        kind: SupplementaryViewKind,
        accessibilityFormat: SupplementaryAccessibilityFormat
    ) {
        self.registrationInfo = registrationInfo
        self.kind = kind
        self.accessibilityFormat = accessibilityFormat
    }
}

/// Defines the kind of a supplementary view.
///
/// - header: indicates that the view is a header
/// - footer: indicates that the view is a footer
public enum SupplementaryViewKind: Equatable {

    /// A header view.
    case header

    /// A footer view.
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
