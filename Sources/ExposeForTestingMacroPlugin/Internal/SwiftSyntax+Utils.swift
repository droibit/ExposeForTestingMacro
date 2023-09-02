import SwiftSyntax

extension AttributeListSyntax {
    func excludeMacroAttribute(_ macroNode: AttributeSyntax) -> AttributeListSyntax {
        filter { syntax in
            guard case let .attribute(attribute) = syntax,
                  let attributeType = attribute.attributeName.as(IdentifierTypeSyntax.self),
                  let macroNodeType = macroNode.attributeName.as(IdentifierTypeSyntax.self)
            else {
                return true
            }
            return attributeType.name.text != macroNodeType.name.text
        }
    }
}

// MARK: - DeclModifier

extension DeclModifierListSyntax {
    var hasStatic: Bool {
        contains { $0.name.tokenKind == .keyword(.static) }
    }

    var hasPrivate: Bool {
        contains(where: \.isPrivate)
    }
}

extension DeclModifierSyntax {
    var isPrivate: Bool {
        name.tokenKind == .keyword(.private)
    }

    var isStatic: Bool {
        name.tokenKind == .keyword(.static)
    }
}

// MARK: - Accessor

extension AccessorBlockSyntax {
    var hasSetter: Bool {
        switch accessors {
        case .getter:
            false
        case let .accessors(accessors):
            accessors.contains { $0.accessorSpecifier.tokenKind == .keyword(.set) }
        }
    }
}

extension AccessorDeclListSyntax {
    var hasGetterOrSetter: Bool {
        contains { $0.isGetter || $0.isSetter }
    }
}

extension AccessorDeclSyntax {
    var isGetter: Bool {
        accessorSpecifier.tokenKind == .keyword(.get)
    }

    var isSetter: Bool {
        accessorSpecifier.tokenKind == .keyword(.set)
    }
}

// MARK: - EffectSpecifiers

extension FunctionEffectSpecifiersSyntax {
    func toCallExpr() -> String {
        var exprs = [String]()
        if throwsSpecifier != nil {
            exprs.append("try")
        }
        if asyncSpecifier != nil {
            exprs.append("await")
        }
        return if exprs.isEmpty {
            ""
        } else {
            "\(exprs.joined(separator: " ")) "
        }
    }
}

extension AccessorEffectSpecifiersSyntax {
    func toCallExpr() -> String {
        var exprs = [String]()
        if throwsSpecifier != nil {
            exprs.append("try")
        }
        if asyncSpecifier != nil {
            exprs.append("await")
        }
        return if exprs.isEmpty {
            ""
        } else {
            "\(exprs.joined(separator: " ")) "
        }
    }
}
