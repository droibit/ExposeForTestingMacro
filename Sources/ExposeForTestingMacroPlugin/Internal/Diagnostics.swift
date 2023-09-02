import SwiftDiagnostics
import SwiftSyntax

private let domain = "ExposeForTestingMacro"

enum ExposeForTestingMacroDiagnostics: Error {
    case notCorrectTarget
    case emptyMacro
}

extension ExposeForTestingMacroDiagnostics: DiagnosticMessage {
    var message: String {
        switch self {
        case .notCorrectTarget:
            "@ExposeForTesting can only be applied to a property or a function."
        case .emptyMacro:
            "@ExposeForTesting needs a name of the defined macro."
        }
    }

    var diagnosticID: MessageID {
        let id = switch self {
        case .notCorrectTarget:
            "notCorrectType"
        case .emptyMacro:
            "emptyMacro"
        }
        return .init(domain: domain, id: id)
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .emptyMacro, .notCorrectTarget: .error
        }
    }
}
