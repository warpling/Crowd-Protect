// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FaceBlur",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "FaceBlur",
            targets: ["FaceBlur"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FaceBlur",
            dependencies: []),
    ]
)
