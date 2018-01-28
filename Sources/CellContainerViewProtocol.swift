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

/**
 This protocol unifies `UICollectionView` and `UITableView` by providing a common dequeue method for cells.
 It describes a view that is the "parent" view for a cell.
 For `UICollectionViewCell`, this would be `UICollectionView`.
 For `UITableViewCell`, this would be `UITableView`.
 */
protocol CellContainerViewProtocol {

    /// The type of cell for this parent view.
    associatedtype CellType: UIView

    /// The type of supplementary view for this parent view.
    associatedtype SupplementaryType: UIView

    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> CellType

    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> SupplementaryType?

    func registerCellClass(_ cellClass: AnyClass?, identifier: String)
    func registerCellNib(_ cellNib: UINib?, identifier: String)

    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String)
    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String)
}

extension CellContainerViewProtocol {
    func registerCellViewModels(_ cellViewModels: [ReusableCellProtocol]) {
        cellViewModels.forEach {
            self.registerCellViewModel($0)
        }
    }

    func registerCellViewModel(_ model: ReusableCellProtocol) {
        let info = model.registrationInfo
        let identifier = info.reuseIdentifier
        let method = info.registrationMethod

        switch method {
        case let .fromClass(classType):
            self.registerCellClass(classType, identifier: identifier)
        case .fromNib:
            self.registerCellNib(method.nib, identifier: identifier)
        }
    }

    func registerSupplementaryViewModel(_ model: ReusableSupplementaryViewProtocol) {
        guard let info = model.viewInfo else { return }
        let identifier = info.registrationInfo.reuseIdentifier
        let method = info.registrationInfo.registrationMethod
        let kind = info.kind

        switch method {
        case let .fromClass(classType):
            self.registerSupplementaryClass(classType, kind: kind, identifier: identifier)
        case .fromNib:
            self.registerSupplementaryNib(method.nib, kind: kind, identifier: identifier)
        }
    }
}

extension UICollectionView: CellContainerViewProtocol {
    typealias CellType = UICollectionViewCell
    typealias SupplementaryType = UICollectionReusableView

    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> SupplementaryType? {
        return self.dequeueReusableSupplementaryView(ofKind: kind.collectionElementKind, withReuseIdentifier: identifier, for: indexPath)
    }

    func registerCellClass(_ cellClass: AnyClass?, identifier: String) {
        self.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    func registerCellNib(_ cellNib: UINib?, identifier: String) {
        self.register(cellNib, forCellWithReuseIdentifier: identifier)
    }

    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String) {
        self.register(supplementaryClass, forSupplementaryViewOfKind: kind.collectionElementKind, withReuseIdentifier: identifier)
    }

    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String) {
        self.register(supplementaryNib, forSupplementaryViewOfKind: kind.collectionElementKind, withReuseIdentifier: identifier)
    }
}

extension UITableView: CellContainerViewProtocol {
    typealias CellType = UITableViewCell
    typealias SupplementaryType = UITableViewHeaderFooterView

    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> SupplementaryType? {
        return self.dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }

    func registerCellClass(_ cellClass: AnyClass?, identifier: String) {
        self.register(cellClass, forCellReuseIdentifier: identifier)
    }

    func registerCellNib(_ cellNib: UINib?, identifier: String) {
        self.register(cellNib, forCellReuseIdentifier: identifier)
    }

    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String) {
        self.register(supplementaryClass, forHeaderFooterViewReuseIdentifier: identifier)
    }

    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String) {
        self.register(supplementaryNib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}
