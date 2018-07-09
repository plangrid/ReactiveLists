# CHANGELOG

The changelog for `ReactiveLists`. Also see the [releases](https://github.com/plangrid/ReactiveLists/releases) on GitHub.

------

0.1.2 (NEXT RELEASE)
-----

### Breaking

- Removed `TableSectionViewModel.collapsed` ([#120](https://github.com/plangrid/ReactiveLists/pull/120), [@jessesquires](https://github.com/jessesquires))

### Changed

- Section and cell view models are now diffable by default. ([#119](https://github.com/plangrid/ReactiveLists/pull/119), [@jessesquires](https://github.com/jessesquires))
Each provide default values for `diffingKey`, but you can customize them for your own needs or opt-out of automatic diffing.
    - `CollectionSectionViewModel` protocol now inherits from `DiffableViewModel` protocol
    - `CollectionCellViewModel` protocol now inherits from `DiffableViewModel` protocol
    - ` TableSectionViewModel` protocol now inherits from `DiffableViewModel` protocol
    - `TableCellViewModel` protocol now inherits from `DiffableViewModel` protocol

0.1.1
-----

This release closes the [0.1.1 milestone](https://github.com/plangrid/ReactiveLists/milestone/3).

### Breaking

- Upgrade to Swift 4.1, Xcode 9.4 now required

### Fixed

- Fix reloading bugs when going from non-nil to nil models
- Improved `TableViewDriver` animations when diffing
- Fixed rare crash caused by UIKit passing a bad `IndexPath` to dequeue cells
- Podspec issues

### New

- You can now customize the cell insertion and deletion animations on `TableViewDriver`. ([#115](https://github.com/plangrid/ReactiveLists/pull/115), [@wickwirew](https://github.com/wickwirew))
- `ViewRegistrationInfo` properties `reuseIdentifier` and `registrationMethod` are now public
- `ViewRegistrationInfo` now conforms to `Equatable`
- `SupplementaryViewInfo` now conforms to `Equatable`
- `SupplementaryViewKind` now conforms to `Equatable`
- `CellAccessibilityFormat` now conforms to `Equatable`
- `SupplementaryAccessibilityFormat` now conforms to `Equatable`

0.1.0
-----

Initial release 🎉
