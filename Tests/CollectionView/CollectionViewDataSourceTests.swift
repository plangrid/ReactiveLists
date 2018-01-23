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
import ReactiveSwift
import UIKit
import XCTest

final class CollectionViewDataSourceTests: XCTestCase {

    private var _collectionView: TestCollectionView!
    private var _collectionViewModel: CollectionViewModel!
    private var _collectionViewDataSource: TestCollectionViewDataSource!

    private var _lastSelectClosureCaller: String?
    private var _lastDeselectClosureCaller: String?

    override func setUp() {
        super.setUp()
        self._collectionView = TestCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        self._collectionViewModel = CollectionViewModel(sectionModels: [
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: 10, viewKind: .header, sectionLabel: "A"),
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: 11, viewKind: .footer, sectionLabel: "A")),
            CollectionViewModel.SectionModel(
                cellViewModels: ["A", "B", "C"].map { self._generateTestCollectionCellViewModel($0) },
                headerViewModel: nil,
                footerViewModel: TestCollectionViewSupplementaryViewModel(label: "footer_B", height: 21)),
            CollectionViewModel.SectionModel(
                cellViewModels: ["D", "E", "F"].map { self._generateTestCollectionCellViewModel($0) },
                headerViewModel: TestCollectionViewSupplementaryViewModel(label: "header_C", height: 30),
                footerViewModel: nil),
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: nil, viewKind: .header, sectionLabel: "D"),
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: nil, viewKind: .footer, sectionLabel: "D")),
        ])
        self._collectionViewDataSource = TestCollectionViewDataSource()
        self._collectionViewDataSource.collectionViewModel.value = self._collectionViewModel
    }

    func testCollectionViewSetup() {
        // Test that the delegate and dataSource connections are made
        XCTAssertNil(self._collectionView.delegate)
        XCTAssertNil(self._collectionView.dataSource)

        self._collectionViewDataSource.label = "baz"
        self._collectionViewDataSource.collectionView = self._collectionView

        XCTAssertEqual((self._collectionView.delegate as? TestCollectionViewDataSource)?.label, "baz")
        XCTAssertEqual((self._collectionView.dataSource as? TestCollectionViewDataSource)?.label, "baz")

        // Test that header and footer view classes explicitly provided in the view model are registered
        let registerCalls = self._collectionView.callsToRegisterClass
        XCTAssertEqual(registerCalls.count, 6)
        self._testRegisterClassCallInfo(registerCalls[0], viewClass: HeaderView.self, kind: .header, identifier: "reuse_header+A")
        self._testRegisterClassCallInfo(registerCalls[1], viewClass: FooterView.self, kind: .footer, identifier: "reuse_footer+A")
        self._testRegisterClassCallInfo(registerCalls[2], viewClass: HeaderView.self, kind: .header, identifier: "reuse_header+D")
        self._testRegisterClassCallInfo(registerCalls[3], viewClass: FooterView.self, kind: .footer, identifier: "reuse_footer+D")

        // Test that the a blank header and footer view class is registered for hidden headers and footers
        // Used for headers and footers that are not explicitly provided in the view model
        self._testRegisterClassCallInfo(registerCalls[4], viewClass: UICollectionReusableView.self, kind: .header, identifier: "hidden-supplementary-view")
        self._testRegisterClassCallInfo(registerCalls[5], viewClass: UICollectionReusableView.self, kind: .footer, identifier: "hidden-supplementary-view")
    }

    func testCollectionViewSections() {
        XCTAssertEqual(self._collectionViewDataSource.numberOfSections(in: self._collectionView), 4)

        parameterize(cases: (section: 0, numberOfItemsInSection: 0), (1, 3), (2, 3), (3, 0), (9, 0)) {
            XCTAssertEqual(self._collectionViewDataSource.collectionView(self._collectionView, numberOfItemsInSection: $0), $1)
        }

        // If the collection view's layout is a FlowLayout, the header/footerReferenceSize will be used if the
        // height of the header/footer is not explicitly provided in the view model
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        layout.footerReferenceSize = CGSize(width: 0, height: 51)

        parameterize(cases: (layout: nil, section: 0, headerHeight: 10), (nil, 1, 0), (nil, 2, 30), (nil, 3, 0), (nil, 9, 0), (layout, 3, 50)) {
            XCTAssertEqual(self._collectionViewDataSource.collectionView(self._collectionView,
                                                                             layout: $0 ?? UICollectionViewLayout(),
                                                                             referenceSizeForHeaderInSection: $1).height, $2)
        }

        parameterize(cases: (layout: nil, section: 0, footerHeight: 11), (nil, 1, 21), (nil, 2, 0), (nil, 3, 0), (nil, 9, 0), (layout, 3, 51)) {
            XCTAssertEqual(self._collectionViewDataSource.collectionView(self._collectionView,
                                                                             layout: $0 ?? UICollectionViewLayout(),
                                                                             referenceSizeForFooterInSection: $1).height, $2)
        }
    }

    func testCollectionViewItems() {
        parameterize(cases: (section: 0, shouldHighlight: true), (1, false), (2, false), (9, true)) {
            XCTAssertEqual(self._collectionViewDataSource.collectionView(self._collectionView, shouldHighlightItemAt: path($0)), $1)
        }
    }

    func testHeaderViews() {
        parameterize(cases:
            (section: 0, expectedAccessibilityIdentifier: "access_header+0", expectedLabel: "label_header+A", expectedIdentifier: "reuse_header+A"),
            // If header view info is not explicitly provided for a section, a hidden header is generated
            // The hidden header can have non-zero height if a height is specified in the view model
            (1, nil as String?, nil as String?, "hidden-supplementary-view"),
            (2, nil, nil, "hidden-supplementary-view"),
            (3, "access_header+3", "label_header+D", "reuse_header+D"),
            (9, nil, nil, "hidden-supplementary-view")) {
            let indexPath = path($0)
            let indexKey = indexPath

            // Test that headers are generated with the correct identifiers and have the correct labels,
            // indicating the view models have been applied
            let header = self._getSupplementaryView(section: $0, kind: .header)
            XCTAssertEqual(header?.accessibilityIdentifier, $1)
            XCTAssertEqual(header?.label, $2)
            XCTAssertEqual(header?.identifier, $3)

            // Test that the header is marked as on screen
            guard let onScreenHeader = self._collectionViewDataSource._headersOnScreen[indexKey] as? TestCollectionReusableView else {
                XCTFail("Did not find the on screen TestCollectionReusableView header")
                return
            }
            XCTAssertEqual(onScreenHeader.label, $2)

            // Test that the header is no longer marked as on screen after didEndDisplaying is called
            self._collectionViewDataSource.collectionView(self._collectionView,
                                                              didEndDisplayingSupplementaryView: onScreenHeader,
                                                              forElementOfKind: UICollectionElementKindSectionHeader,
                                                              at: indexPath)
            XCTAssertNil(self._collectionViewDataSource._headersOnScreen[indexKey])
        }
    }

    func testFooterViews() {
        parameterize(cases:
            (section: 0, expectedAccessibilityIdentifier: "access_footer+0", expectedLabel: "label_footer+A", expectedIdentifier: "reuse_footer+A"),
            // If footer view info is not explicitly provided for a section, a hidden footer is generated
            // The hidden footer can have non-zero height if a height is specified in the view model
            (1, nil as String?, nil as String?, "hidden-supplementary-view"),
            (2, nil, nil, "hidden-supplementary-view"),
            (3, "access_footer+3", "label_footer+D", "reuse_footer+D"),
            (9, nil, nil, "hidden-supplementary-view")) {
            let indexPath = path($0)
            let indexKey = indexPath

            // Test that footers are generated with the correct identifiers and have the correct labels and accessibilityIdentifiers,
            // indicating the view models have been applied
            let footer = self._getSupplementaryView(section: $0, kind: .footer)
            XCTAssertEqual(footer?.accessibilityIdentifier, $1)
            XCTAssertEqual(footer?.label, $2)
            XCTAssertEqual(footer?.identifier, $3)

            // Test that the footer is marked as on screen
            guard let onScreenFooter = self._collectionViewDataSource._footersOnScreen[indexKey] as? TestCollectionReusableView else {
                XCTFail("Did not find the on screen TestCollectionReusableView header")
                return
            }
            XCTAssertEqual(onScreenFooter.label, $2)

            // Test that the footer is no longer marked as on screen after didEndDisplaying is called
            self._collectionViewDataSource.collectionView(self._collectionView,
                                                              didEndDisplayingSupplementaryView: onScreenFooter,
                                                              forElementOfKind: UICollectionElementKindSectionFooter,
                                                              at: indexPath)
            XCTAssertNil(self._collectionViewDataSource._footersOnScreen[indexKey])
        }
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

        // Test that the item is marked as on screen
        guard let onScreenCell = self._collectionViewDataSource._cellsOnScreen[indexPath] as? TestCollectionViewCell else {
            XCTFail("Did not find the on screen TestCollectionViewCell")
            return
        }
        XCTAssertEqual(onScreenCell.label, "C")

        // Test that the item is no longer marked as on screen after didEndDisplaying is called
        self._collectionViewDataSource.collectionView(self._collectionView, didEndDisplaying: onScreenCell, forItemAt: indexPath)
        XCTAssertNil(self._collectionViewDataSource._cellsOnScreen[indexPath])
    }

    func testCellCallbacks() {
        let dataSource = self._collectionViewDataSource

        parameterize(cases: (0, nil), (9, nil), (1, "A")) { (section: Int, caller: String?) in
            let indexPath = path(section)
            dataSource?.collectionView(self._collectionView, didSelectItemAt: indexPath)
            dataSource?.collectionView(self._collectionView, didDeselectItemAt: indexPath)

            XCTAssertEqual(self._lastSelectClosureCaller, caller)
            XCTAssertEqual(self._lastDeselectClosureCaller, caller)
        }
    }

    func testShouldDeselectUponSelection() {
        // Default is to deselect upong selection
        let dataSource = TestCollectionViewDataSource()
        let collectionView = TestCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        dataSource.collectionView = collectionView
        XCTAssertEqual(collectionView.callsToDeselect, 0)
        dataSource.collectionView(collectionView, didSelectItemAt: path(0))
        XCTAssertEqual(collectionView.callsToDeselect, 1)
    }

    func testShouldNotDeselectUponSelection() {
        let dataSource = TestCollectionViewDataSource(shouldDeselectUponSelection: false)
        let collectionView = TestCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        dataSource.collectionView = collectionView
        XCTAssertEqual(collectionView.callsToDeselect, 0)
        dataSource.collectionView(collectionView, didSelectItemAt: path(0))
        XCTAssertEqual(collectionView.callsToDeselect, 0)
    }

    func testRefreshViews() {
        let item = self._getItem(path(1, 0))
        let header = self._getSupplementaryView(section: 0, kind: .header)
        let footer = self._getSupplementaryView(section: 0, kind: .footer)

        XCTAssertEqual(item?.label, "A")
        XCTAssertEqual(header?.label, "label_header+A")
        XCTAssertEqual(footer?.label, "label_footer+A")

        self._collectionViewDataSource.collectionViewModel.value = CollectionViewModel(sectionModels: [
            CollectionViewModel.SectionModel(
                cellViewModels: nil,
                headerViewModel: TestCollectionViewSupplementaryViewModel(height: 10, viewKind: .header, sectionLabel: "X"),
                footerViewModel: TestCollectionViewSupplementaryViewModel(height: 11, viewKind: .footer, sectionLabel: "X")),
            CollectionViewModel.SectionModel(
                cellViewModels: [self._generateTestCollectionCellViewModel("X")],
                headerViewModel: nil,
                footerViewModel: nil),
        ])

        XCTAssertEqual(item?.label, "X")
        XCTAssertEqual(header?.label, "label_header+X")
        XCTAssertEqual(footer?.label, "label_footer+X")

        XCTAssertEqual(item?.accessibilityIdentifier, "access-1.0")
        XCTAssertEqual(header?.accessibilityIdentifier, "access_header+0")
        XCTAssertEqual(footer?.accessibilityIdentifier, "access_footer+0")
    }

    private func _getItem(_ path: IndexPath) -> TestCollectionViewCell? {
        guard let cell = self._collectionViewDataSource.collectionView(self._collectionView,
                                                                           cellForItemAt: path) as? TestCollectionViewCell else { return nil }
        return cell
    }

    private func _getSupplementaryView(section: Int, kind: SupplementaryViewKind) -> TestCollectionReusableView? {
        guard let view = self._collectionViewDataSource.collectionView(
            self._collectionView,
            viewForSupplementaryElementOfKind: kind == .header ? UICollectionElementKindSectionHeader : UICollectionElementKindSectionFooter,
            at: path(section)
        ) as? TestCollectionReusableView else { return nil }

        return view
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

private typealias _RegisterClassCallInfo = (viewClass: AnyClass?, viewKind: SupplementaryViewKind?, reuseIdentifier: String)
private class TestCollectionView: UICollectionView {

    var callsToRegisterClass: [_RegisterClassCallInfo?] = []
    var callsToDeselect: Int = 0

    override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return TestCollectionViewCell(identifier: identifier)
    }

    override func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionReusableView {
        return TestCollectionReusableView(identifier: identifier)
    }

    override func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        if let viewClass = viewClass {
            self.callsToRegisterClass.append((viewClass, SupplementaryViewKind(collectionElementKindString: elementKind), identifier))
        } else {
            self.callsToRegisterClass.append(nil)
        }
    }

    override func deselectItem(at indexPath: IndexPath, animated: Bool) {
        self.callsToDeselect += 1
    }
}

private class TestCollectionViewDataSource: CollectionViewDataSource {
    var label: String?
}
