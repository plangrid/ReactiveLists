// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "ReactiveLists",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "ReactiveLists", targets: ["ReactiveLists"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ra1028/DifferenceKit.git", .upToNextMinor(from: "1.1.3")),
    ],
    targets: [
        .target(
            name: "ReactiveLists",
            dependencies: ["DifferenceKit"],
            path: "Sources"
        ),
        .testTarget(
            name: "ReactiveListsTests",
            dependencies: ["ReactiveLists"],
            path: "Tests"
        ),
    ]
)
