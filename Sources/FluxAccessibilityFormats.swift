//
//  FluxAccessibilityFormats.swift
//  PlanGrid
//
//  Created by Kiefer Aguilar on 3/3/16.
//  Copyright © 2016 PlanGrid. All rights reserved.
//

import Foundation

/// Wrapper `struct` for the `accessibilityIdentifier` format that should be applied to the cells of a `UITableView` or a `UICollectionView`
public struct CellAccessibilityFormat: ExpressibleByStringLiteral {
    private let _format: String

    public init(_ format: String) {
        self._format = format
    }

    public init(stringLiteral value: StringLiteralType) {
        self._format = value
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self._format = value
    }

    public init(unicodeScalarLiteral value: String) {
        self._format = value
    }

    public func accessibilityIdentifierForIndexPath(_ indexPath: IndexPath) -> String {
        return self._format.replacingOccurrences(of: "%{section}", with: String(indexPath.section))
            .replacingOccurrences(of: "%{item}", with: String(indexPath.item))
            .replacingOccurrences(of: "%{row}", with: String(indexPath.row))
    }
}

/// Wrapper `struct` for the `accessibilityIdentifier` format that should be applied to the headers and footers of a `UITableView` or a `UICollectionView`
public struct SupplementaryAccessibilityFormat: ExpressibleByStringLiteral {
    private let _format: String

    public init(_ format: String) {
        self._format = format
    }

    public init(stringLiteral value: StringLiteralType) {
        self._format = value
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self._format = value
    }

    public init(unicodeScalarLiteral value: String) {
        self._format = value
    }

    public func accessibilityIdentifierForSection(_ section: Section) -> String {
        return self._format.replacingOccurrences(of: "%{section}", with: String(section))
    }
}
