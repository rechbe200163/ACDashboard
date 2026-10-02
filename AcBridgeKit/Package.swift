// swift-tools-version: 6.0
import PackageDescription

// Gemeinsame Logik für iPad- und Mac-App: Modelle, WebSocket-Client, ViewModels.
// Keine SwiftUI-Views hier drin, die bleiben in den Apps.
let package = Package(
    name: "AcBridgeKit",
    platforms: [
        .iOS(.v17),     // @Observable braucht iOS 17 / macOS 14
        .macOS(.v14),
    ],
    products: [
        .library(name: "AcBridgeKit", targets: ["AcBridgeKit"]),
    ],
    targets: [
        .target(name: "AcBridgeKit"),
        .testTarget(name: "AcBridgeKitTests", dependencies: ["AcBridgeKit"]),
    ]
)
