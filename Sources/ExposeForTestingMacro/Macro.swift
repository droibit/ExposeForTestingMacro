/// A Swift macro to expose private properties and functions for unit tests.
///
/// For example:
///
/// ```swift
/// class Test {
///     @ExposeForTesting
///     private var value: String = ""
///
///     @ExposeForTesting
///     private func test(_ v1: String, v2: String) -> String {
///          value + v1 + v2
///     }
/// }
/// ```
///
/// generated:
///
/// ```swift
/// class Test {
///     private var value: String = ""
///
///     #if TESTING
///     var _value: String {
///         get {
///             return value
///         }
///         set {
///             value = newValue
///         }
///     }
///     #endif
///
///     private func test(_ v1: String, v2: String) -> String {
///          value + v1 + v2
///     }
///
///     #if TESTING
///     func _test(_ v1: String, v2: String) -> String {
///         test(v1, v2: v2)
///     }
///     #endif
/// }
/// ```
///
/// - Parameter macroName: The name of the macro for a compilation condition.
@attached(peer, names: arbitrary)
public macro ExposeForTesting(
    macroName: String = "TESTING"
) = #externalMacro(
    module: "ExposeForTestingMacroPlugin",
    type: "ExposeForTestingMacro"
)
