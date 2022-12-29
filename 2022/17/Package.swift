// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "main",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "part1", targets: ["part1"]),
        .executable(name: "part2", targets: ["part2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(name: "part1", dependencies: [
            .product(name: "Algorithms", package: "swift-algorithms"),
        ]),
        .executableTarget(name: "part2", dependencies: [
            .product(name: "Algorithms", package: "swift-algorithms"),
        ]),
    ]
)
