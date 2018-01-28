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

public protocol ReusableSupplementaryViewProtocol {

    /// The registration info for the supplementary view.
    var viewInfo: SupplementaryViewInfo? { get } // TODO: make this not optional
}

/// Metadata thats required for setting up a supplementary view.
public struct SupplementaryViewInfo {
    /// Stores how the view was registered (as a class or via a nib file)
    public let registrationMethod: ViewRegistrationMethod
    /// The reuse identifier for this supplementary view
    public let reuseIdentifier: String
    /// The kind of supplementary view (e.g. `header` or `footer`)
    public let kind: SupplementaryViewKind

    /// `TableViewDataSource` and `CollectionViewDataSource` will automatically apply
    /// an `accessibilityIdentifier` to the supplementary view based on this format.
    public let accessibilityFormat: SupplementaryAccessibilityFormat

    /// Initializes the metadata for a supplementary view.
    ///
    /// - Parameters:
    ///   - registrationMethod: describes how the view was registered (as a class or via a nib file)
    ///   - reuseIdentifier: reuse identifier for this supplementary view
    ///   - kind: kind of supplementary view (e.g. `header` or `footer`)
    ///   - accessibilityFormat: a format string that generates an accessibility identifier for
    ///                          the view that will be mapped to this view model.
    public init(
        registrationMethod: ViewRegistrationMethod,
        reuseIdentifier: String,
        kind: SupplementaryViewKind,
        accessibilityFormat: SupplementaryAccessibilityFormat
    ) {
        self.registrationMethod = registrationMethod
        self.reuseIdentifier = reuseIdentifier
        self.kind = kind
        self.accessibilityFormat = accessibilityFormat
    }
}

/// Defines the kind of a supplementary view.
///
/// - header: indicates that the view is a header
/// - footer: indicates that the view is a footer
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
