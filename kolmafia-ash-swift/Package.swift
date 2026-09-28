// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "kolmafia-ash-swift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "KoLmafiaASH", targets: ["KoLmafiaASH"]),
        .executable(name: "ashrefgen", targets: ["AshrefGen"]),
        .executable(name: "ash-readonly-example", targets: ["ReadOnlyExample"]),
    ],
    targets: [
        .target(name: "KoLmafiaASH"),
        .executableTarget(name: "AshrefGen", dependencies: ["KoLmafiaASH"]),
        .executableTarget(name: "ReadOnlyExample", dependencies: ["KoLmafiaASH"]),
        .testTarget(name: "KoLmafiaASHTests", dependencies: ["KoLmafiaASH"]),
    ]
)
