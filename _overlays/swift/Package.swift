// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MySwiftLib",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(name: "MySwiftLib", targets: ["MySwiftLib"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "MySwiftLib", dependencies: []),
        .testTarget(name: "MySwiftLibTests", dependencies: ["MySwiftLib"]),
    ]
)
