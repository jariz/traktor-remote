// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TraktorRemoteControl",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "TraktorRemoteControl",
            type: .dynamic,
            targets: ["TraktorRemoteControl"]
        )
    ],
    targets: [
        .target(
            name: "Core",
            path: "Sources/Core"
        ),
        .executableTarget(
            name: "traktor-remote",
            dependencies: ["Core"],
            path: "Sources/CLI"
        ),
        .target(
            name: "DylibEntry",
            dependencies: ["Core"],
            path: "Sources/DylibEntry"
        ),
        .target(
            name: "TraktorRemoteControl",
            dependencies: ["DylibEntry"],
            path: "Sources/Dylib"
        )
    ]
)
