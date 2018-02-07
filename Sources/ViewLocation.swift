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
