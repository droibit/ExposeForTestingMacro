// swiftlint:disable type_body_length function_body_length

import Foundation
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ExposeForTestingMacroPlugin

final class ExposeForTestingMacroPluginTests: XCTestCase {
    private let macros: [String: Macro.Type] = [
        "ExposeForTesting": ExposeForTestingMacro.self,
    ]

    func test_expansion_forProperties() {
        assertMacroExpansion(
            """
            class Test {
                @ExposeForTesting
                private var value1: String
                @ExposeForTesting
                private let value2: Int
                @ExposeForTesting
                private(set) var value3: Float
                @ExposeForTesting
                private lazy var value4: String = "value4"

                @ExposeForTesting
                private var value5: String {
                    "value2"
                }

                @ExposeForTesting
                private var value5_1: String {
                    get { value2 }
                }

                @ExposeForTesting
                private var value5_2: String {
                    get async throws { value2 }
                }

                @ExposeForTesting
                private var value6: String {
                    get { value2 }
                    set { value2 = newValue }
                }

                @ExposeForTesting
                private var value7: Int = 0 {
                    willSet(newValue) {
                    }
                    didSet {
                    }
                }

                @ExposeForTesting
                fileprivate var value8: String = ""
                @ExposeForTesting
                internal var value9: String = ""
                @ExposeForTesting
                var value10: String = ""
                @ExposeForTesting
                public var value11: String = ""

                @ExposeForTesting
                private static var Value1: String = ""
                @ExposeForTesting
                private static let Value2: String = ""

                init(
                    value1: String = "",
                    value2: Int = 0,
                    value3: Float = 0.0
                ) {
                    self.value1 = value1
                    self.value2 = value2
                    self.value3 = value3
                }
            }
            """,
            expandedSource:
            """
            class Test {
                private var value1: String

                #if TESTING
                var _value1: String {
                    get {
                        return value1
                    }
                    set {
                        value1 = newValue
                    }
                }
                #endif
                private let value2: Int

                #if TESTING
                var _value2: Int {
                    return value2
                }
                #endif
                private(set) var value3: Float

                #if TESTING
                var _value3: Float {
                    get {
                        return value3
                    }
                    set {
                        value3 = newValue
                    }
                }
                #endif
                private lazy var value4: String = "value4"

                #if TESTING
                var _value4: String {
                    get {
                        return value4
                    }
                    set {
                        value4 = newValue
                    }
                }
                #endif
                private var value5: String {
                    "value2"
                }

                #if TESTING
                var _value5: String {
                    return value5
                }
                #endif
                private var value5_1: String {
                    get { value2 }
                }

                #if TESTING
                var _value5_1: String {
                    get {
                        return value5_1
                    }
                }
                #endif
                private var value5_2: String {
                    get async throws { value2 }
                }

                #if TESTING
                var _value5_2: String {
                    get async throws {
                        return try await value5_2
                    }
                }
                #endif
                private var value6: String {
                    get { value2 }
                    set { value2 = newValue }
                }

                #if TESTING
                var _value6: String {
                    get {
                        return value6
                    }
                    set {
                        value6 = newValue
                    }
                }
                #endif
                private var value7: Int = 0 {
                    willSet(newValue) {
                    }
                    didSet {
                    }
                }

                #if TESTING
                var _value7: Int {
                    get {
                        return value7
                    }
                    set {
                        value7 = newValue
                    }
                }
                #endif
                fileprivate var value8: String = ""
                internal var value9: String = ""
                var value10: String = ""
                public var value11: String = ""
                private static var Value1: String = ""

                #if TESTING
                static var _Value1: String {
                    get {
                        return Value1
                    }
                    set {
                        Value1 = newValue
                    }
                }
                #endif
                private static let Value2: String = ""

                #if TESTING
                static var _Value2: String {
                    return Value2
                }
                #endif

                init(
                    value1: String = "",
                    value2: Int = 0,
                    value3: Float = 0.0
                ) {
                    self.value1 = value1
                    self.value2 = value2
                    self.value3 = value3
                }
            }
            """,
            macros: macros
        )
    }

    func test_expansion_forFunctions() throws {
        assertMacroExpansion(
            """
            struct Test {
                private var value1: String = ""

                @ExposeForTesting
                private func test1() {
                    print("test")
                }

                @ExposeForTesting
                private func test2(_ v1: String, value2: String) async throws -> String {
                    v1 + value2
                }

                @ExposeForTesting
                private mutating func test3() {
                    value = "updated"
                }

                @ExposeForTesting
                fileprivate func test4() {
                }

                @ExposeForTesting
                internal func test5() {
                }

                @ExposeForTesting
                internal func test6() {
                }

                @ExposeForTesting
                public func test7() {
                }

                @ExposeForTesting
                private static func test8() {
                }
            }
            """,
            expandedSource:
            """
            struct Test {
                private var value1: String = ""
                private func test1() {
                    print("test")
                }

                #if TESTING
                func _test1()  {
                    test1()
                }
                #endif
                private func test2(_ v1: String, value2: String) async throws -> String {
                    v1 + value2
                }

                #if TESTING
                func _test2(_ v1: String, value2: String) async throws -> String  {
                    try await test2(v1, value2: value2)
                }
                #endif
                private mutating func test3() {
                    value = "updated"
                }

                #if TESTING
                mutating func _test3()  {
                    test3()
                }
                #endif
                fileprivate func test4() {
                }
                internal func test5() {
                }
                internal func test6() {
                }
                public func test7() {
                }
                private static func test8() {
                }

                #if TESTING
                static func _test8()  {
                    test8()
                }
                #endif
            }
            """,
            macros: macros
        )
    }
}
