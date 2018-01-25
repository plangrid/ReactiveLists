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

/// The method for registering cells and supplementary views
public enum ViewRegistrationMethod {
    /// Class-based views
    case viewClass(AnyClass)
    /// Nib-based views
    case nib(name: String, bundle: Bundle?)
}

extension ViewRegistrationMethod: Equatable {
    public static func == (lhs: ViewRegistrationMethod, rhs: ViewRegistrationMethod) -> Bool {
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
