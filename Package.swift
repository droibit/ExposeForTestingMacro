// swift-tools-version: 5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ExposeForTestingMacro",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ExposeForTestingMacro",
            targets: ["ExposeForTestingMacro"]
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
            name: "ExposeForTestingMacro",
            dependencies: [
                "ExposeForTestingMacroPlugin",
            ]
        ),
        .macro(
            name: "ExposeForTestingMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "ExposeForTestingMacroPluginTests",
            dependencies: [
                "ExposeForTestingMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
