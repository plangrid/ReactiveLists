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

/// Describes the registration information for a cell or supplementary view.
public struct ViewRegistrationInfo {

    /// The reuse identifier for the view.
    let reuseIdentifier: String

    /// The registration method for the view.
    let registrationMethod: ViewRegistrationMethod

    /// Initializes a new `ViewRegistrationInfo` for the provided `classType`.
    ///
    /// - Note:
    /// The class name is used for `reuseIdentifier`.
    /// The `registrationMethod` is set to `.fromClass`.
    ///
    /// - Parameter classType: The cell or supplementary view class.
    public init(classType: AnyClass) {
        self.reuseIdentifier = "\(classType)"
        self.registrationMethod = .fromClass(classType)
    }

    /// Initializes a new `ViewRegistrationInfo` for the provided `classType`, `nibName`, and `bundle`.
    ///
    /// - Note:
    /// The class name is used for `reuseIdentifier`.
    /// The `registrationMethod` is set to `.fromNib` using the provided `nibName` and `bundle`.
    ///
    /// - Parameters:
    ///   - classType: The cell or supplementary view class.
    ///   - nibName: The name of the nib for the view.
    ///   - bundle: The bundle in which the nib is located. Pass `nil` to use the main bundle.
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
