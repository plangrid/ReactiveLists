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

import Differ
import Foundation

extension NestedExtendedDiff {
    /// Initializes a `NestedExtendedDiff` from a `NestedDiff`
    init(_ diff: NestedDiff) {
        self.init(
            elements: diff.elements.map {
                switch $0 {
                case let .deleteSection(section):
                    return .deleteSection(section)
                case let .insertSection(section):
                    return .insertSection(section)
                case let .deleteElement(element, section):
                    return .deleteElement(element, section: section)
                case let .insertElement(element, section):
                    return .insertElement(element, section: section)
                }
            }
        )
    }
}
