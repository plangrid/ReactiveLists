# CHANGELOG

The changelog for `ReactiveLists`. Also see the [releases](https://github.com/plangrid/ReactiveLists/releases) on GitHub.

------

0.4.0 (NEXT)
------------

This release closes the [0.4.0 milestone](https://github.com/plangrid/ReactiveLists/milestone/10).

### Breaking

- Improve semantics of row height API ([#154](https://github.com/plangrid/ReactiveLists/pull/154), [@asmallteapot](https://github.com/asmallteapot))
    - Make `TableCellViewModel.rowHeight` optional, defaulting to `nil`
    - Add `TableViewModel.defaultRowHeight`, defaulting to `44.0`

- Upgrades SwiftLint to 0.30.1 ([#149](https://github.com/plangrid/ReactiveLists/pull/149), [@anayini](https://github.com/anayini))

- Updates the initializers for `TableSectionViewModel` and `CollectionSectionViewModel` so that the `diffingKey` argument is _required_. This prevents accidental misuse of the automatic diffing API, which was possible if you relied on the previous default parameter value. ([#147](https://github.com/plangrid/ReactiveLists/pull/147), [@ronaldsmartin](https://github.com/ronaldsmartin))

- Upgrades DifferenceKit to 0.8.0  ([#153](https://github.com/plangrid/ReactiveLists/pull/153), [@anayini](https://github.com/anayini))

### Changed

- Use `allSatisfy(_:)` in places where we would use `first(where:)` and a `nil` check

- Upgrade to SwiftLint 0.29.1

0.3.0
-----

This release closes the [0.3.0 milestone](https://github.com/plangrid/ReactiveLists/milestone/9).

### New

- Drop iOS 9 and migrate to Swift 4.2 ([#144](https://github.com/plangrid/ReactiveLists/pull/144), [@benasher44](https://github.com/benasher44))

0.2.0
-----

This release closes the [0.2.0 milestone](https://github.com/plangrid/ReactiveLists/milestone/2).

### Fixed

- Auto-diffing bugs and crashes ([#136](https://github.com/plangrid/ReactiveLists/pull/136), [@benasher44](https://github.com/benasher44))

### New

- `TableSectionViewModel` and `CollectionSectionViewModel` now implement `Collection` ([#135](https://github.com/plangrid/ReactiveLists/pull/135), [@benasher44](https://github.com/benasher44))

- [DifferenceKit](https://github.com/ra1028/DifferenceKit) is now used instead of Dwifft for faster diffing ([#136](https://github.com/plangrid/ReactiveLists/pull/136), [@benasher44](https://github.com/benasher44))

0.1.4
-----

This release closes the [0.1.4 milestone](https://github.com/plangrid/ReactiveLists/milestone/7).

### Fixed

- Don't store an empty model for the first non-nil differ. ([#137](https://github.com/plangrid/ReactiveLists/pull/137), [@benasher44](https://github.com/benasher44))

0.1.3
-----

This release closes the [0.1.3 milestone](https://github.com/plangrid/ReactiveLists/milestone/6).

### Breaking

- Changes `TableViewModel.subscript` and `CollectionViewModel.subscript` methods that return an `Optional` by adding the `ifExists:` parameter name (separating them from future non-`Optional` `Collection` subscripts) ([#131](https://github.com/plangrid/ReactiveLists/pull/131), [@benasher44](https://github.com/benasher44))

### Fixed

- Fix edge case reloading bug when reloading a table view with diffing disabled ([#128](https://github.com/plangrid/ReactiveLists/pull/128), [@benasher44](https://github.com/benasher44))

0.1.2
-----

This release closes the [0.1.2 milestone](https://github.com/plangrid/ReactiveLists/milestone/4).

### Breaking

- Removed `TableSectionViewModel.collapsed` ([#121](https://github.com/plangrid/ReactiveLists/pull/121), [@jessesquires](https://github.com/jessesquires))

- Removed undocumented initializers for `CollectionSectionViewModel` (the ones that received `headerHeight:` and/or `footerHeight:`) ([#123](https://github.com/plangrid/ReactiveLists/pull/123), [@jessesquires](https://github.com/jessesquires))

- `CollectionViewDriver.automaticDiffingEnabled` is no longer public ([#125](https://github.com/plangrid/ReactiveLists/pull/125), [@jessesquires](https://github.com/jessesquires))

### Fixed

- Fixed a crash in diffing when transitioning to or from empty/nil states ([#125](https://github.com/plangrid/ReactiveLists/pull/125), [@jessesquires](https://github.com/jessesquires))

- Fixed incorrect calculation for `TableViewModel.isEmpty`. It now correctly returns true only if all sections return `true` for `isEmpty`. ([#123](https://github.com/plangrid/ReactiveLists/pull/123), [@jessesquires](https://github.com/jessesquires))

### New

- Added `CollectionSectionViewModel.isEmpty` property ([#123](https://github.com/plangrid/ReactiveLists/pull/123), [@jessesquires](https://github.com/jessesquires))

- Added `CollectionViewModel.isEmpty` property ([#123](https://github.com/plangrid/ReactiveLists/pull/123), [@jessesquires](https://github.com/jessesquires))

### Changed

- Section and cell view models are now diffable by default. ([#119](https://github.com/plangrid/ReactiveLists/pull/119), [@jessesquires](https://github.com/jessesquires))
Each provide default values for `diffingKey`, but you can customize them for your own needs or opt-out of automatic diffing.
    - `CollectionSectionViewModel` protocol now inherits from `DiffableViewModel` protocol
    - `CollectionCellViewModel` protocol now inherits from `DiffableViewModel` protocol
    - ` TableSectionViewModel` protocol now inherits from `DiffableViewModel` protocol
    - `TableCellViewModel` protocol now inherits from `DiffableViewModel` protocol

- `CollectionViewDriver.automaticDiffingEnabled` was reverted to be `false` by default ([#125](https://github.com/plangrid/ReactiveLists/pull/125), [@jessesquires](https://github.com/jessesquires))

### ⚠️ Known issues ⚠️

- Automatic diffing for collection views with multiple sections currently fails (crashes) and possibly won't work in other scenarios. (Thus, the reason why auto-diffing is now `false` for `CollectionViewDriver`.) This will be fixed in the next release. Tracking at [#126](https://github.com/plangrid/ReactiveLists/pull/126).

0.1.1-patch1
-----

### Fixed

- Fix edge case reloading bug when reloading a table view with diffing disabled

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

------

0.1.0
-----

Initial release 🎉
