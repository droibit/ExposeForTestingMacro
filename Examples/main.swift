import ExposeForTestingMacro
import Foundation

class Test {
    @ExposeForTesting
    private var value1: String
    @ExposeForTesting
    private let value2: Int
    @ExposeForTesting
    private(set) var value3: Float

    @ExposeForTesting
    private var value4: String {
        "value4"
    }

    @ExposeForTesting
    private var value4_1: String { value4 }

    @ExposeForTesting
    private var value4_2: String {
        get async throws { value4 }
    }

    @ExposeForTesting
    private var value4_3: String {
        get throws { value4 }
    }

    @ExposeForTesting
    private var value5: String {
        get { value1 }
        set(newValue) { value1 = newValue }
    }

    @ExposeForTesting
    private lazy var value6: String = ""
    @ExposeForTesting
    private var value7: String = "test"

    @ExposeForTesting
    private static var Value1: String = "Value1"
    @ExposeForTesting
    private static let Value2: String = "Value2"

    init(
        value1: String = "",
        value2: Int = 0,
        value3: Float = 0.0
    ) {
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
    }

    @ExposeForTesting
    private func test() async throws {
//        value7 = ""
    }
}

let test = Test()
test._value1 = "test"
