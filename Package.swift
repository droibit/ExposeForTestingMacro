// swift-tools-version: 5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ExpandForTestingMacro",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ExpandForTestingMacro",
            targets: ["ExpandForTestingMacro"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-08-15-a"
        ),
    ],
    targets: [
        .target(
            name: "ExpandForTestingMacro",
            dependencies: [
                "ExpandForTestingMacroPlugin",
            ]
        ),
        .macro(
            name: "ExpandForTestingMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "ExpandForTestingMacroPluginTests",
            dependencies: [
                "ExpandForTestingMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [
                .define("TESTING"),
            ]
        ),
        .executableTarget(
            name: "Examples",
            dependencies: [
                "ExpandForTestingMacro",
            ],
            path: "Examples",
            swiftSettings: [
                .define("TESTING"),
            ]
        ),
    ]
)
