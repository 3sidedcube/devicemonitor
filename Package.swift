// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Device-Monitor",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        .package(url: "https://github.com/3sidedcube/ferno.git", .branch("jwt3")),
        
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.1"),
        
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "0.6.3")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Ferno", "Jobs", "FCM"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

