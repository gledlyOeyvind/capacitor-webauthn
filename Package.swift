// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorWebauthn",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorWebauthn",
            targets: ["WebAuthnPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "WebAuthnPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/WebAuthnPluginPlugin"),
        .testTarget(
            name: "WebAuthnPluginPluginTests",
            dependencies: ["WebAuthnPluginPlugin"],
            path: "ios/Tests/WebAuthnPluginPluginTests")
    ]
)