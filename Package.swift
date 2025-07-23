// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Rudder-Firebase",
    platforms: [
        .iOS("12.0"), .tvOS("13.0")
    ],
    products: [
        .library(
            name: "Rudder-Firebase",
            targets: ["Rudder-Firebase"]),
    ],
    dependencies: [
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", .exact("11.15.0")),
        .package(name: "Rudder", url: "https://github.com/rudderlabs/rudder-sdk-ios", from: "1.0.0"),
    ],

    targets: [
        .target(
            name: "Rudder-Firebase",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "Firebase"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Rudder-Firebase",
            sources: ["Classes/"],
            publicHeadersPath: "Classes/",
            cSettings: [
                .headerSearchPath("Classes/")
            ]
        ),
    ]
)