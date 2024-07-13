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

/// Protocol for providing `CollectionViewModel`s to a `CollectionSectionViewModel`
///
/// It is itself the `Collection` of `CollectionCellViewModel` and
/// also provides hooks for pre-fetching data
///
/// - Note: `[TableCellViewModel]` has a default implementation
public protocol CollectionCellViewModelDataSourceProtocol: RandomAccessCollection where Element == CollectionCellViewModel, Index == Int {

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
public struct CollectionCellViewModelDataSource: RandomAccessCollection {

    // MARK: `CollectionCellViewModelDataSourceProtocol` wrapper blocks for type erasure

    /// :nodoc:
    private let _subscriptBlock: (Int) -> CollectionCellViewModel

    /// :nodoc:
    private let _prefetchBlock: (AnySequence<Int>) -> Void

    /// :nodoc:
    private let _prefetchCancelBlock: (AnySequence<Int>) -> Void

    /// Initializes the `CollectionCellViewModelDataSource` with the provided `CollectionCellViewModelDataSourceProtocol` implementation
    public init<DataSource: CollectionCellViewModelDataSourceProtocol>(_ dataSource: DataSource) {
        self.init(dataSource, cellRegistrationInfo: dataSource.cellRegistrationInfo)
    }

    /// Used internally by the public init and during diffing
    /// when cached ``ViewRegistrationInfo` is available
    init<DataSource: CollectionCellViewModelDataSourceProtocol>(_ dataSource: DataSource, cellRegistrationInfo: [ViewRegistrationInfo]) {
        self._prefetchBlock = dataSource.prefetchRowsAt
        self._prefetchCancelBlock = dataSource.cancelPrefetchingRowsAt
        self._subscriptBlock = { dataSource[$0] }
        self.startIndex = dataSource.startIndex
        self.endIndex = dataSource.endIndex
        self.cellRegistrationInfo = cellRegistrationInfo
    }

    // MARK: - Protocol Implementation

    /// :nodoc:
    public let cellRegistrationInfo: [ViewRegistrationInfo]

    /// :nodoc:
    func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int {
        self._prefetchBlock(AnySequence(indices))
    }

    /// :nodoc:
    func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int { self._prefetchCancelBlock(AnySequence(indices)) }

    /// :nodoc:
    public typealias Element = CollectionCellViewModel

    /// :nodoc:
    public typealias Index = Int

    /// :nodoc:
    public subscript(position: Int) -> CollectionCellViewModel {
        self._subscriptBlock(position)
    }

    /// :nodoc:
    public let startIndex: Int

    /// :nodoc:
    public let endIndex: Int
}

extension Array: CollectionCellViewModelDataSourceProtocol where Element == CollectionCellViewModel {

    /// :nodoc:
    public func prefetchRowsAt<S: Sequence>(indices: S) where S.Element == Int {}

    /// :nodoc:
    public func cancelPrefetchingRowsAt<S: Sequence>(indices: S) where S.Element == Int {}

    /// :nodoc:
    public var cellRegistrationInfo: [ViewRegistrationInfo] {
        self.map {
            $0.registrationInfo
        }
    }
}

//extension Array where Element == IndexPath {j
//
//    /// Helper that transforms `[IndexPath]` to sequence of pairs of sections and row sequences
//    func indicesBySection() -> AnySequence<(Int, AnySequence<Int>)> {
//        let indexPathsBySection = [Int: [IndexPath]](grouping: self) { $0.section }
//        return AnySequence(indexPathsBySection.lazy.map { section, indexPaths in
//            return (section, AnySequence(indexPaths.lazy.map { $0.row }))
//        })
//    }
//}
