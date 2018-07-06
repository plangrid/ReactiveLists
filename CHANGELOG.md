# CHANGELOG

The changelog for `ReactiveLists`. Also see the [releases](https://github.com/plangrid/ReactiveLists/releases) on GitHub.

------

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

- `ViewRegistrationInfo` properties `reuseIdentifier` and `registrationMethod` are now public
- `ViewRegistrationInfo` now conforms to `Equatable`
- `SupplementaryViewInfo` now conforms to `Equatable`
- `SupplementaryViewKind` now conforms to `Equatable`
- `CellAccessibilityFormat` now conforms to `Equatable`
- `SupplementaryAccessibilityFormat` now conforms to `Equatable`

0.1.0
-----

Initial release 🎉
