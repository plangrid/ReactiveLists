//
//  ViewLocation.swift
//  PlanGrid
//
//  Created by Kiefer Aguilar on 3/1/16.
//  Copyright © 2016 PlanGrid. All rights reserved.
//

import Foundation

public typealias Section = Int

/// Simple `enum` to associate a location (NSIndexPath or Section) with each type of view
public enum ViewLocation {
    case cell(IndexPath)
    case header(Section)
    case footer(Section)

    /// Returns indexPath iff ViewKind is a .Cell
    public var indexPath: IndexPath? {
        switch self {
        case let .cell(indexPath):
            return indexPath
        default:
            return nil
        }
    }

    /// Returns section iff ViewKind is a .Header or .Footer
    public var section: Section? {
        switch self {
        case let .header(section):
            return section
        case let .footer(section):
            return section
        default:
            return nil
        }
    }
}
