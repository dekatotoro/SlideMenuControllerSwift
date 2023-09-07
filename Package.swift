// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlideMenuControllerSwift",
    products: [
        .library(name: "SlideMenuControllerSwift",
                 targets: ["SlideMenuControllerSwift"])
    ],
    targets: [
        .target(
            name: "SlideMenuControllerSwift",
            path: "Source")
    ]
)
