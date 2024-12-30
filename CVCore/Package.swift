// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CVCore",
    platforms: [
        .iOS(.v15), // Update to iOS 15
        .macOS(.v12) // Update to macOS 12
    ],
    products: [
        .library(
            name: "CVCore",
            targets: ["CVCore"]),
    ],
    targets: [
        .target(
            name: "CVCore",
            dependencies: []),
        .testTarget(
            name: "CVCoreTests",
            dependencies: ["CVCore"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
