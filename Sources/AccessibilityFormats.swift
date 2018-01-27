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

// Note: The accessibility types below are not documented as they are not intended to be part
// of the `ReactiveLists` project in the long term. See https://github.com/plangrid/ReactiveLists/issues/77

/// :nodoc:
public struct CellAccessibilityFormat: ExpressibleByStringLiteral {
    private let _format: String

    /// :nodoc:
    public init(_ format: String) {
        self._format = format
    }

    /// :nodoc:
    public init(stringLiteral value: StringLiteralType) {
        self._format = value
    }

    /// :nodoc:
    public init(extendedGraphemeClusterLiteral value: String) {
        self._format = value
    }

    /// :nodoc:
    public init(unicodeScalarLiteral value: String) {
        self._format = value
    }

    /// :nodoc:
    public func accessibilityIdentifierForIndexPath(_ indexPath: IndexPath) -> String {
        return self._format.replacingOccurrences(of: "%{section}", with: String(indexPath.section))
            .replacingOccurrences(of: "%{item}", with: String(indexPath.item))
            .replacingOccurrences(of: "%{row}", with: String(indexPath.row))
    }
}

/// :nodoc:
public struct SupplementaryAccessibilityFormat: ExpressibleByStringLiteral {
    private let _format: String

    /// :nodoc:
    public init(_ format: String) {
        self._format = format
    }

    /// :nodoc:
    public init(stringLiteral value: StringLiteralType) {
        self._format = value
    }

    /// :nodoc:
    public init(extendedGraphemeClusterLiteral value: String) {
        self._format = value
    }

    /// :nodoc:
    public init(unicodeScalarLiteral value: String) {
        self._format = value
    }

    /// :nodoc:
    public func accessibilityIdentifierForSection(_ section: Int) -> String {
        return self._format.replacingOccurrences(of: "%{section}", with: String(section))
    }
}
