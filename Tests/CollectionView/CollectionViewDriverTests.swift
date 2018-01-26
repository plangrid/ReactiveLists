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

@testable import ReactiveLists
import UIKit
import XCTest

final class CollectionViewDriverTests: XCTestCase {

    var collectionView: TestCollectionView!
    var viewModel: CollectionViewModel!
    var driver: CollectionViewDriver!

    var _lastSelectClosureCaller: String?
    var _lastDeselectClosureCaller: String?

    override func setUp() {
        super.setUp()
        self.collectionView = TestCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 600), collectionViewLayout: UICollectionViewFlowLayout())
        self.viewModel = CollectionViewModel(sectionModels: [
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: 10, viewKind: .header, sectionLabel: "A"),
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: 11, viewKind: .footer, sectionLabel: "A")),
            CollectionViewModel.SectionModel(
                cellViewModels: ["A", "B", "C"].map { self._generateTestCollectionCellViewModel($0) },
                headerViewModel: nil,
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: 21, viewKind: .footer, sectionLabel: "B")),
            CollectionViewModel.SectionModel(
                cellViewModels: ["D", "E", "F"].map { self._generateTestCollectionCellViewModel($0) },
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: 30, viewKind: .header, sectionLabel: "C"),
                footerViewModel: nil),
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: 40, viewKind: .header, sectionLabel: "D"),
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: 40, viewKind: .footer, sectionLabel: "D")),
        ])
        self.driver = CollectionViewDriver(
            collectionView: self.collectionView,
            collectionViewModel: self.viewModel,
            automaticDiffingEnabled: false
        )
    }

    func testCollectionViewSetup() {
        // Test that the delegate and dataSource connections are made
        XCTAssertNotNil(self.collectionView.delegate)
        XCTAssertNotNil(self.collectionView.dataSource)

        // FIXME:

        // Test that header and footer view classes explicitly provided in the view model are registered
//        let registerCalls = self.collectionView.callsToRegisterClass
//        XCTAssertEqual(registerCalls.count, 6)
//        self._testRegisterClassCallInfo(registerCalls[0], viewClass: HeaderView.self, kind: .header, identifier: "reuse_header+A")
//        self._testRegisterClassCallInfo(registerCalls[1], viewClass: FooterView.self, kind: .footer, identifier: "reuse_footer+A")
//        self._testRegisterClassCallInfo(registerCalls[2], viewClass: FooterView.self, kind: .footer, identifier: "reuse_footer+B")
//        self._testRegisterClassCallInfo(registerCalls[3], viewClass: HeaderView.self, kind: .header, identifier: "reuse_header+C")
//        self._testRegisterClassCallInfo(registerCalls[4], viewClass: HeaderView.self, kind: .header, identifier: "reuse_header+D")
//        self._testRegisterClassCallInfo(registerCalls[5], viewClass: FooterView.self, kind: .footer, identifier: "reuse_footer+D")
    }

    func testCollectionViewSections() {
        // TODO:
    }

    func testCollectionViewItems() {
        parameterize(cases: (section: 0, shouldHighlight: true), (1, false), (2, false), (9, true)) {
            XCTAssertEqual(self.driver.collectionView(self.collectionView, shouldHighlightItemAt: path($0)), $1)
        }
    }

    func testThatHeaderViewsHaveCorrectSetup() {
        // TODO:
    }

    func testFooterViews() {
        // TODO:
    }

    func testNonExistingCollectionViewItems() {
        parameterize(cases: path(0, 0), path(1, 9), path(9, 0)) {
            XCTAssertNil(self._getItem($0))
        }
    }

    func testExistingCollectionViewItem() {
        let indexPath = path(1, 2)
        let cell = self._getItem(indexPath)
        XCTAssertEqual(cell?.label, "C")
        XCTAssertEqual(cell?.accessibilityIdentifier, "access-1.2")
    }

    func testCellCallbacks() {
        let dataSource = self.driver

        parameterize(cases: (0, nil), (9, nil), (1, "A")) { (section: Int, caller: String?) in
            let indexPath = path(section)
            dataSource?.collectionView(self.collectionView, didSelectItemAt: indexPath)
            dataSource?.collectionView(self.collectionView, didDeselectItemAt: indexPath)

            XCTAssertEqual(self._lastSelectClosureCaller, caller)
            XCTAssertEqual(self._lastDeselectClosureCaller, caller)
        }
    }

    func testShouldDeselectUponSelection() {
        // Default is to deselect upong selection
        let collectionView = TestCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        let dataSource = CollectionViewDriver(collectionView: collectionView)
        XCTAssertEqual(collectionView.callsToDeselect, 0)
        dataSource.collectionView(collectionView, didSelectItemAt: path(0))
        XCTAssertEqual(collectionView.callsToDeselect, 1)
    }

    func testShouldNotDeselectUponSelection() {
        let collectionView = TestCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        let dataSource = CollectionViewDriver(collectionView: collectionView, shouldDeselectUponSelection: false)
        XCTAssertEqual(collectionView.callsToDeselect, 0)
        dataSource.collectionView(collectionView, didSelectItemAt: path(0))
        XCTAssertEqual(collectionView.callsToDeselect, 0)
    }

    func testRefreshViews() {
        var item = self._getItem(path(1, 0))
        var header = self._getSupplementaryView(section: 0, kind: .header)
        var footer = self._getSupplementaryView(section: 0, kind: .footer)

        XCTAssertEqual(item?.label, "A")
        XCTAssertEqual(header?.label, "label_header+A")
        XCTAssertEqual(footer?.label, "label_footer+A")

        self.driver.collectionViewModel = CollectionViewModel(sectionModels: [
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: 10, viewKind: .header, sectionLabel: "X"),
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: 11, viewKind: .footer, sectionLabel: "X")),
            CollectionViewModel.SectionModel(
                cellViewModels: [self._generateTestCollectionCellViewModel("X")],
                headerViewModel: nil,
                footerViewModel: nil),
        ])

        item = self._getItem(path(1, 0))
        header = self._getSupplementaryView(section: 0, kind: .header)
        footer = self._getSupplementaryView(section: 0, kind: .footer)

        XCTAssertEqual(item?.label, "X")
        XCTAssertEqual(header?.label, "label_header+X")
        XCTAssertEqual(footer?.label, "label_footer+X")

        XCTAssertEqual(item?.accessibilityIdentifier, "access-1.0")
        XCTAssertEqual(header?.accessibilityIdentifier, "access_header+0")
        XCTAssertEqual(footer?.accessibilityIdentifier, "access_footer+0")
    }

    private func _getItem(_ path: IndexPath) -> TestCollectionViewCell? {
        guard let cell = self.driver.collectionView(self.collectionView,
                                                                           cellForItemAt: path) as? TestCollectionViewCell else { return nil }
        return cell
    }

    private func _getSupplementaryView(section: Int, kind: SupplementaryViewKind) -> TestCollectionReusableView? {
        var size = CGSize.zero
        switch kind {
        case .header:
            size = self.driver.collectionView(self.collectionView,
                                                                 layout: self.collectionView.collectionViewLayout,
                                                                 referenceSizeForHeaderInSection: section)
        case .footer:
            size = self.driver.collectionView(self.collectionView,
                                                                 layout: self.collectionView.collectionViewLayout,
                                                                 referenceSizeForFooterInSection: section)
        }

        let hasView = (size != .zero)
        if !hasView {
            return nil
        }

        return self.driver.collectionView(self.collectionView,
                                                             viewForSupplementaryElementOfKind: kind.collectionViewKind,
                                                             at: path(section)) as? TestCollectionReusableView
    }

    private func _generateTestCollectionCellViewModel(_ label: String) -> TestCollectionCellViewModel {
        return TestCollectionCellViewModel(label: label,
                                           didSelectClosure: { [weak self] in self?._lastSelectClosureCaller = label },
                                           didDeselectClosure: { [weak self] in self?._lastDeselectClosureCaller = label })
    }

    private func _testRegisterClassCallInfo(_ info: _RegisterClassCallInfo?, viewClass: AnyClass, kind: SupplementaryViewKind, identifier: String) {
        XCTAssert(info?.viewClass === viewClass)
        XCTAssertEqual(info?.viewKind, kind)
        XCTAssertEqual(info?.reuseIdentifier, identifier)
    }
}
