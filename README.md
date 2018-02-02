<img src="https://raw.githubusercontent.com/plangrid/ReactiveLists/master/Resources/logo.png"/>

*React-like API for `UITableView` & `UICollectionView`*

[![Build Status](https://travis-ci.org/plangrid/ReactiveLists.svg?branch=master)](https://travis-ci.org/plangrid/ReactiveLists) [![Version Status](https://img.shields.io/cocoapods/v/ReactiveLists.svg)][podLink] [![license MIT](https://img.shields.io/cocoapods/l/ReactiveLists.svg)][mitLink] [![codecov](https://codecov.io/gh/plangrid/ReactiveLists/branch/master/graph/badge.svg)](https://codecov.io/gh/plangrid/ReactiveLists) [![Platform](https://img.shields.io/cocoapods/p/ReactiveLists.svg)][docsLink]

`ReactiveLists` provides a React-like API for `UITableView` and `UICollectionView` that makes it easy to write stateless code that generates user interfaces. 

In our experience this can make UI code significantly easier to read and maintain. Instead of spreading the definition of your content over various data source methods, you can define the content concisely. The table or collection content and layout are immediately obvious by scanning over the source code.

## Features

- React-like declarative API for `UITableView` and `UICollectionView`
- Automatic UI updates, whenever your models change

## Project Status

An early version of  the `UITableView` support has been shipping in the [PlanGrid app](https://itunes.apple.com/us/app/plangrid-construction-software/id498795789?mt=8) since late 2015 and is now used accross wide parts of the app. The support for `UICollectionView` is less mature as we only use `UICollectionView` in very few places.

| Feature                    |     Status      |
| -------------------------- | :-------------: |
| `UITableView` support      |        ✅        |
| `UICollectionView` support | ⚠️ Experimental |

## Vision

For long-term goals and direction, please see [`VISION.md`](https://github.com/plangrid/ReactiveLists/blob/master/Guides/VISION.md).

## Getting Started

Read our [Getting Started Guide](https://github.com/plangrid/ReactiveLists/blob/master/Guides/Getting%20Started.md) to learn how to use `ReactiveLists`.

## Documentation

Read our [documentation here][docsLink]. Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

#### Generating docs

```bash
$ ./scripts/gen_docs.sh
```

## Requirements

* Xcode 9+
* Swift 4.0+
* iOS 9+

## Installation

### [Cocoapods](https://cocoapods.org/) (recommended)

```ruby
use_frameworks!

# For latest release in cocoapods
pod 'ReactiveLists'

# Latest on master branch
pod 'ReactiveLists', :git => 'https://github.com/plangrid/ReactiveLists.git', :branch => 'master'
```

## Contribute

Please read and follow our [Contributing Guide](https://github.com/plangrid/ReactiveLists/blob/master/.github/CONTRIBUTING.md) and our [Code of Conduct](https://github.com/plangrid/ReactiveLists/blob/master/CODE_OF_CONDUCT.md).

## License

`ReactiveLists` is released under an [MIT License][mitLink]. See `LICENSE` for details.

> **Copyright &copy; 2018-present PlanGrid, Inc.**

[docsLink]:https://plangrid.github.io/ReactiveLists
[podLink]:https://cocoapods.org/pods/ReactiveLists
[mitLink]:https://opensource.org/licenses/MIT
