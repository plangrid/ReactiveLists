# ReactiveLists

*React-like API for `UITableView` & `UICollectionView`*

[![Build Status](https://travis-ci.org/plangrid/ReactiveLists.svg?branch=master)](https://travis-ci.org/plangrid/ReactiveLists) [![Version Status](https://img.shields.io/cocoapods/v/ReactiveLists.svg)][podLink] [![license MIT](https://img.shields.io/cocoapods/l/ReactiveLists.svg)][mitLink] [![codecov](https://codecov.io/gh/plangrid/ReactiveLists/branch/master/graph/badge.svg)](https://codecov.io/gh/plangrid/ReactiveLists) [![Platform](https://img.shields.io/cocoapods/p/ReactiveLists.svg)][docsLink]

## About

For long-term goals and direction, please see [`VISION.md`](https://github.com/plangrid/ReactiveLists/blob/master/Guides/VISION.md).

## Requirements

* Xcode 9+
* Swift 4.0+
* iOS 9+

## Getting Started Guide

Please see our [Getting Started](https://github.com/plangrid/ReactiveLists/blob/master/Guides/Getting%20Started.md) guide to learn how to use ReactiveLists


#### `SectionModel`

This is the type that describes a given section within your `UITableView` or `UICollectionView`.

#### `CellViewModel`

This is the type that describes the data that to configure a given cell in your `UITableView` or
`UICollectionView`.


#### `ViewModel`

`TableViewModel` and `CollectionViewModel` are types that describe what your `UITableView` or `UICollectionView`
should look like.  You initialize such a `ViewModel` with a set of `SectionModel`s, which
in turn are initialized with a set of `CellViewModel`s.  After doing this, your `ViewModel`
contains all the data required to render your `UITableView` or `UICollectionView`

#### `Driver`

`TableViewDriver` and `CollectionViewDriver` are responsible for calling all the methods to update your view
when new data is available.  You initialize your `Driver` with a `UITableView` or `UICollectionView` and then
as new data becomes available, you construct a new `ViewModel` and set the `Driver`'s `tableViewModel` or `collectionViewModel` property to the new `ViewModel`  From there the `Driver` will figure out the differences in the data and re-render your
`UITableView` or `UICollectionView` automatically for you.


## Installation

### [Cocoapods](https://cocoapods.org/) (recommended)

```ruby
use_frameworks!

# For latest release in cocoapods
pod 'ReactiveLists'

# Latest on master branch
pod 'ReactiveLists', :git => 'https://github.com/plangrid/ReactiveLists.git', :branch => 'master'
```

## Documentation

Read our [documentation here][docsLink]. Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

#### Generating docs

```bash
$ ./scripts/gen_docs.sh
```

## Contribute

Please read and follow our [Contributing Guide](https://github.com/plangrid/ReactiveLists/blob/master/.github/CONTRIBUTING.md) and our [Code of Conduct](https://github.com/plangrid/ReactiveLists/blob/master/CODE_OF_CONDUCT.md).

## License

`ReactiveLists` is released under an [MIT License][mitLink]. See `LICENSE` for details.

> **Copyright &copy; 2018-present PlanGrid, Inc.**

[docsLink]:https://plangrid.github.io/ReactiveLists
[podLink]:https://cocoapods.org/pods/ReactiveLists
[mitLink]:https://opensource.org/licenses/MIT
