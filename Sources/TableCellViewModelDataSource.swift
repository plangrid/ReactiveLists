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

/// Protocol for providing `TableCellViewModel`s to a `TableSectionViewModel`
///
/// It is itself the `Collection` of `TableCellViewModel` and
/// also provides hooks for pre-fetching data
///
/// - Note: `[TableCellViewModel]` has a default implementation
public protocol TableCellViewModelDataSourceProtocol: RandomAccessCollection where Element == TableCellViewModel, Index == Int {

    /// Called by the equivalent `UITableViewDataSourcePrefetching` method
    /// - Parameter indices: The indices in the section, for which to prefetch the models
    func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int

    /// Called by the equivalent `UITableViewDataSourcePrefetching` method
    /// - Parameter indices: The indices in the section, for which to cancel prefetchign the models
    func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int

    /// The `ViewRegistrationInfo` for the cells represented by this datasource
    var cellRegistrationInfo: [ViewRegistrationInfo] { get }
}

/// The concrete data source that wraps a provided `TableCellViewModelDataSourceProtocol` implementation
public struct TableCellViewModelDataSource: RandomAccessCollection {

    // MARK: `TableCellViewModelDataSourceProtocol` wrapper blocks for type erasure

    /// :nodoc:
    private let _subscriptBlock: (Int) -> TableCellViewModel

    /// :nodoc:
    private let _startIndexBlock: () -> Int

    /// :nodoc:
    private let _endIndexBlock: () -> Int

    /// :nodoc:
    private let _prefetchBlock: (AnySequence<Int>) -> Void

    /// :nodoc:
    private let _prefetchCancelBlock: (AnySequence<Int>) -> Void

    /// Initializes the `TableCellViewModelDataSource` with the provided `TableCellViewModelDataSourceProtocol` implementation
    public init<DataSource: TableCellViewModelDataSourceProtocol>(_ dataSource: DataSource) {
        self._prefetchBlock = dataSource.prefetchRowsAt
        self._prefetchCancelBlock = dataSource.cancelPrefetchingRowsAt
        self._subscriptBlock = { dataSource[$0] }
        self._startIndexBlock = { dataSource.startIndex }
        self._endIndexBlock = { dataSource.endIndex }
        self.cellRegistrationInfo = dataSource.cellRegistrationInfo
    }

    // MARK: -  Protocol Implementation

    /// :nodoc:
    public let cellRegistrationInfo: [ViewRegistrationInfo]

    /// :nodoc:
    func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int {
        self._prefetchBlock(AnySequence(indices))
    }

    /// :nodoc:
    func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int { self._prefetchCancelBlock(AnySequence(indices)) }

    /// :nodoc:
    public typealias Element = TableCellViewModel

    /// :nodoc:
    public typealias Index = Int

    /// :nodoc:
    public subscript(position: Int) -> TableCellViewModel {
        self._subscriptBlock(position)
    }

    /// :nodoc:
    public var startIndex: Int { self._startIndexBlock() }

    /// :nodoc:
    public var endIndex: Int { self._endIndexBlock() }
}

extension Array: TableCellViewModelDataSourceProtocol where Element == TableCellViewModel {

    /// :nodoc:
    public func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int {}

    /// :nodoc:
    public func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int {}

    /// :nodoc:
    public var cellRegistrationInfo: [ViewRegistrationInfo] {
        self.map { $0.registrationInfo }
    }
}

extension Array where Element == IndexPath {

    /// Helper that transforms `[IndexPath]` to sequence of pairs of sections and row sequences
    func indicesBySection() -> AnySequence<(Int, AnySequence<Int>)> {
        let indexPathsBySection = [Int: [IndexPath]](grouping: self) { $0.section }
        return AnySequence(indexPathsBySection.lazy.map { section, indexPaths in
            return (section, AnySequence(indexPaths.lazy.map { $0.row }))
        })
    }
}
