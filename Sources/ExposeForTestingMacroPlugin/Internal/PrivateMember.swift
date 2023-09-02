import SwiftSyntax

// MARK: - Property

extension VariableDeclSyntax {
    func asPrivate(with macroNode: AttributeSyntax) -> VariableDeclSyntax? {
        var newModifiers = modifiers.filter { !$0.isPrivate }
        guard newModifiers.count != modifiers.count else {
            return nil
        }
        newModifiers = newModifiers.filter(\.isStatic)

        guard
            let binding = bindings.first?.as(PatternBindingSyntax.self),
            let variableName = binding.pattern.as(IdentifierPatternSyntax.self),
            let variableType = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type,
            case let .keyword(keyword) = bindingSpecifier.tokenKind
        else {
            return nil
        }

        // Drop the @ExposeForTesting attribute from the new declaration.
        let newAttributes = attributes.excludeMacroAttribute(macroNode)
        let newType = "\(variableType)".trimmingCharacters(in: .whitespaces)
        let newAccessorBlock: AccessorBlockSyntax? = switch keyword {
        case .let:
            AccessorBlockSyntax(accessors: .getter(with: variableName))
        case .var:
            if let accessorBlock = binding.accessorBlock {
                AccessorBlockSyntax(
                    accessors: AccessorBlockSyntax.Accessors(
                        from: accessorBlock.accessors,
                        with: variableName
                    )
                )
            } else {
                AccessorBlockSyntax(accessors: .accessors(with: variableName))
            }
        default:
            nil
        }

        guard let newAccessorBlock else {
            return nil
        }
        return VariableDeclSyntax(
            attributes: newAttributes,
            modifiers: newModifiers,
            bindingSpecifier: .keyword(.var),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: PatternSyntax("_\(raw: variableName)"),
                    typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax("\(raw: newType)")),
                    accessorBlock: newAccessorBlock
                )
            }
        )
    }
}

private extension AccessorBlockSyntax.Accessors {
    init(from accessorsSyntax: Self, with variableName: IdentifierPatternSyntax) {
        switch accessorsSyntax {
        case let .accessors(accessors):
            if accessors.hasGetterOrSetter {
                self = .accessors(
                    AccessorDeclListSyntax {
                        if let getter = accessors.first(where: \.isGetter) {
                            AccessorDeclSyntax(
                                accessorSpecifier: .keyword(.get),
                                effectSpecifiers: getter.effectSpecifiers
                            ) {
                                let callExpr = getter.effectSpecifiers?.toCallExpr() ?? ""
                                StmtSyntax("return \(raw: callExpr)\(raw: variableName)")
                            }
                        }
                        if accessors.contains(where: \.isSetter) {
                            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                                ExprSyntax("\(raw: variableName) = newValue")
                            }
                        }
                    }
                )
            } else {
                self = .accessors(with: variableName)
            }
        case .getter:
            self = .getter(with: variableName)
        }
    }

    static func accessors(with variableName: IdentifierPatternSyntax) -> Self {
        .accessors(
            AccessorDeclListSyntax {
                AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                    StmtSyntax("return \(raw: variableName)")
                }
                AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                    ExprSyntax("\(raw: variableName) = newValue")
                }
            }
        )
    }

    static func getter(with variableName: IdentifierPatternSyntax) -> Self {
        .getter(
            CodeBlockItemListSyntax {
                "return \(raw: variableName)"
            }
        )
    }
}

// MARK: - Function

extension FunctionDeclSyntax {
    func asPrivate(with macroNode: AttributeSyntax) -> FunctionDeclSyntax? {
        let newModifiers = modifiers.filter { !$0.isPrivate }
        guard newModifiers.count != modifiers.count else {
            return nil
        }

        // Drop the @ExposeForTesting attribute from the new declaration.
        let newAttributes = attributes.excludeMacroAttribute(macroNode)
        let parameters = signature.parameterClause.parameters
        let callArguments: [String] = parameters.map { param in
            let argName = param.secondName ?? param.firstName
            let paramName = param.firstName
            return if paramName.text != "_" {
                "\(paramName.text): \(argName.text)"
            } else {
                "\(argName.text)"
            }
        }

        let callExpr = signature.effectSpecifiers?.toCallExpr() ?? ""
        let newBody = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space),
            statements: CodeBlockItemListSyntax {
                """
                \(raw: callExpr)\(raw: name)(\(raw: callArguments.joined(separator: ", ")))
                """
            },
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        return with(\.name, TokenSyntax(stringLiteral: "_\(name)"))
            .with(\.attributes, newAttributes)
            .with(\.modifiers, newModifiers)
            .with(\.body, newBody)
            .with(\.leadingTrivia, .newlines(1))
    }
}
