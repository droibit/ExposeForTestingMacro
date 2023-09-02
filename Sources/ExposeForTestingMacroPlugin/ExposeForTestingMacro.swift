import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct ExposeForTestingMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            declaration.is(VariableDeclSyntax.self) ||
            declaration.is(FunctionDeclSyntax.self)
        else {
            let error = Diagnostic(
                node: node._syntaxNode,
                message: ExposeForTestingMacroDiagnostics.notCorrectTarget
            )
            context.diagnose(error)
            return []
        }

        let args = if case let .argumentList(arguments) = node.arguments {
            Arguments(arguments)
        } else {
            Arguments()
        }

        let ifConfigBody: CodeBlockItemListSyntax
        if let variableDecl = declaration.as(VariableDeclSyntax.self) {
            guard let privateProp = variableDecl.asPrivate(with: node) else {
                return []
            }
            ifConfigBody = CodeBlockItemListSyntax { privateProp }
        } else {
            guard
                let funcDecl = declaration.as(FunctionDeclSyntax.self),
                let privateFunc = funcDecl.asPrivate(with: node)
            else {
                return []
            }
            ifConfigBody = CodeBlockItemListSyntax { privateFunc }
        }

        let ifConfigDecl = IfConfigDeclSyntax(
            clauses: IfConfigClauseListSyntax {
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(),
                    condition: ExprSyntax("\(raw: args.macroName)"),
                    elements: .statements(ifConfigBody)
                )
            },
            poundEndif: .poundEndifToken(
                trailingTrivia: .newlines(2)
            )
        )
        return [DeclSyntax(ifConfigDecl)]
    }
}
