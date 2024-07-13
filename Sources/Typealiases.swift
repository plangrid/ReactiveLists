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

/// :nodoc:
public typealias CommitEditingStyleClosure = (UITableViewCell.EditingStyle) -> Void
/// :nodoc:
public typealias DidSelectClosure = () -> Void
/// :nodoc:
public typealias DidDeleteClosure = () -> Void
/// :nodoc:
public typealias DidDeselectClosure = () -> Void
/// :nodoc:
public typealias WillBeginEditingClosure = () -> Void
/// :nodoc:
public typealias DidEndEditingClosure = () -> Void
/// :nodoc:
public typealias AccessoryButtonTappedClosure = () -> Void
/// :nodoc:
public typealias DidScrollClosure = (UIScrollView) -> Void
