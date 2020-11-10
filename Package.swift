// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TrashCanKit",

    products: [
        .library(
            name: "TrashCanKit",
            targets: ["TrashCanKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdishbynature/RequestKit.git", from: "2.4.0"),
    ],
    targets: [
        .target(
            name: "TrashCanKit",
            dependencies: ["RequestKit"]
         ),
        .testTarget(
            name: "TrashCanKitTests",
            dependencies: ["TrashCanKit"]),
    ]
)