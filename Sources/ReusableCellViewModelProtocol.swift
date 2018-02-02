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

/// Describes a cell view model.
/// Unifies table cell and collection cell view models.
public protocol ReusableCellViewModelProtocol {

    /// The registration info for the cell.
    var registrationInfo: ViewRegistrationInfo { get }
}

/// Describes a supplementary view model.
/// Unifies table supplementary and collection supplementary view models.
public protocol ReusableSupplementaryViewModelProtocol {

    /// The registration info for the supplementary view.
    var viewInfo: SupplementaryViewInfo? { get }
}
