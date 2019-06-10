// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "WolfLocation",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "WolfLocation",
            targets: ["WolfLocation"]),
        ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfKit", .branch("Swift-5.1")),
    ],
    targets: [
        .target(
            name: "WolfLocation",
            dependencies: [
                "WolfKit",
            ])
        ]
)
