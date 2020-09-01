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

import DifferenceKit
import Foundation

public protocol TableCellViewModelDataSourceProtocol: RandomAccessCollection where Element == TableCellViewModel, Index == Int {

    func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int

    func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int

    var cellRegistrationInfo: [ViewRegistrationInfo] { get }
}

public struct TableCellViewModelDataSource: RandomAccessCollection {

    public typealias Element = TableCellViewModel
    public typealias Index = Int

    private let _subscriptBlock: (Int) -> TableCellViewModel
    private let _startIndexBlock: () -> Int
    private let _endIndexBlock: () -> Int

    private let _prefetchBlock: (AnySequence<Int>) -> Void
    private let _prefetchCancelBlock: (AnySequence<Int>) -> Void

    public let cellRegistrationInfo: [ViewRegistrationInfo]

    init<DataSource: TableCellViewModelDataSourceProtocol>(_ dataSource: DataSource) {
        self._prefetchBlock = dataSource.prefetchRowsAt
        self._prefetchCancelBlock = dataSource.cancelPrefetchingRowsAt
        self._subscriptBlock = { dataSource[$0] }
        self._startIndexBlock = { dataSource.startIndex }
        self._endIndexBlock = { dataSource.endIndex }
        self.cellRegistrationInfo = dataSource.cellRegistrationInfo
    }

    func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int {
        self._prefetchBlock(AnySequence(indices))
    }

    func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int { self._prefetchCancelBlock(AnySequence(indices)) }

    public subscript(position: Int) -> TableCellViewModel {
        self._subscriptBlock(position)
    }

    public var startIndex: Int { self._startIndexBlock() }
    public var endIndex: Int { self._endIndexBlock() }
}

extension Array: TableCellViewModelDataSourceProtocol where Element == TableCellViewModel {
    public func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int {}
    public func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int {}
    public var cellRegistrationInfo: [ViewRegistrationInfo] {
        self.map { $0.registrationInfo }
    }
}

extension Array where Element == IndexPath {
    func indicesBySection() -> AnySequence<(Int, AnySequence<Int>)> {
        let indexPathsBySection = [Int: [IndexPath]](grouping: self) { $0.section }
        return AnySequence(indexPathsBySection.lazy.map { section, indexPaths in
            return (section, AnySequence(indexPaths.lazy.map { $0.row }))
        })
    }
}
