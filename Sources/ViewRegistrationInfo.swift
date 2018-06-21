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

public protocol ReusableCellProtocol {

    /// The registration info for the cell.
    var registrationInfo: ViewRegistrationInfo { get }
}

public struct ViewRegistrationInfo: Equatable {
    public let reuseIdentifier: String
    public let registrationMethod: ViewRegistrationMethod

    public init(classType: AnyClass) {
        self.reuseIdentifier = "\(classType)"
        self.registrationMethod = .fromClass(classType)
    }

    public init(classType: AnyClass, nibName: String, bundle: Bundle? = nil) {
        self.reuseIdentifier = "\(classType)"
        self.registrationMethod = .fromNib(name: nibName, bundle: bundle)
    }
}

/// The method for registering cells and supplementary views
public enum ViewRegistrationMethod {

    /// Class-based views
    case fromClass(AnyClass)

    /// Nib-based views
    case fromNib(name: String, bundle: Bundle?)

    var nib: UINib? {
        switch self {
        case let .fromNib(name, bundle):
            return UINib(nibName: name, bundle: bundle)
        case .fromClass:
            return nil
        }
    }
}

extension ViewRegistrationMethod: Equatable {
    public static func == (lhs: ViewRegistrationMethod, rhs: ViewRegistrationMethod) -> Bool {
        switch (lhs, rhs) {
        case let (.fromClass(lhsClass), .fromClass(rhsClass)):
            return lhsClass == rhsClass
        case let (.fromNib(lhsName, lhsBundle), .fromNib(rhsName, rhsBundle)):
            return lhsName == rhsName && lhsBundle == rhsBundle
        default:
            return false
        }
    }
}
