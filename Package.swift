// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlideMenuControllerSwift",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "SlideMenuControllerSwift",
            targets: ["SlideMenuControllerSwift"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "SlideMenuControllerSwift")
    ]
)
