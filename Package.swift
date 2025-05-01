// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeckNavigation",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DeckNavigation",
            targets: ["DeckNavigation"]
        ),
    ],
    targets: [
        .target(name: "DeckNavigation"),
    ]
)
