import SwiftSyntax

struct Arguments {
    let macroName: String

    init(macroName: String = "TESTING") {
        self.macroName = macroName
    }
}

extension Arguments {
    init(_ arguments: LabeledExprListSyntax) {
        if let macroName = arguments.first(where: { "\($0)".contains("macroName") })?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.compactMap({ syntax in
                if case let .stringSegment(segment) = syntax {
                    segment.content.text
                } else {
                    nil
                }
            }).first
        {
            self.init(macroName: macroName)
        } else {
            self.init()
        }
    }
}
