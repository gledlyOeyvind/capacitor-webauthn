// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorWebauthn",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorWebauthn",
            targets: ["WebAuthnPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "WebAuthnPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/WebAuthn"),
        .testTarget(
            name: "WebAuthnPluginTests",
            dependencies: ["WebAuthnPlugin"],
            path: "ios/Tests/WebAuthnPluginTests")
    ]
)