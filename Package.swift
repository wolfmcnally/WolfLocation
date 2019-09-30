// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "WolfLocation",
    platforms: [
        .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(
            name: "WolfLocation",
            targets: ["WolfLocation"]),
        ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfKit", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "WolfLocation",
            dependencies: ["WolfKit"])
        ]
)
