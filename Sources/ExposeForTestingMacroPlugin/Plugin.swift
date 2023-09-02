#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct ExposeForTestingMacroPlugin: CompilerPlugin {
        let providingMacros: [Macro.Type] = [
            ExposeForTestingMacro.self,
        ]
    }
#endif
