import XCTest
@testable import Parsers

final class ParsersTests: XCTestCase {
    func dyckTest() {
        struct DyckParser: Parser {
            typealias Stream = String
            typealias Output = Int
            typealias Failure = Never
            
            var parse: PrimitiveParser<String, Int, Never> {
                AllOf {
                    Parsers.prefix("(", stream: String.self)
                    self
                    Parsers.prefix(")", stream: String.self)
                    self
                }
                .map({ (_, inner, _, outer) in inner + 1 + outer })
                .replaceFailures(withValue: 0)
            }
        }
        
        let dyckParser = DyckParser()
        
        let example1 = "(()())()"
        let result1 = dyckParser.parse(from: example1)
        XCTAssert(result1.value == 4)
        XCTAssert(result1.endIndex == example1.endIndex)
        
        let example2 = "())()"
        let result2 = dyckParser.parse(from: example2)
        XCTAssert(result2.value == 1)
        XCTAssert(result2.endIndex == example2.index(example2.startIndex, offsetBy: 3))
    }
}
