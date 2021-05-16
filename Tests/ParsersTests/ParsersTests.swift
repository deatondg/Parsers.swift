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
                .catch(0)
            }
        }
        
        let dyckParser = DyckParser()
        
        let example1 = "(()())()"
        let result1 = dyckParser.parse(example1)
        XCTAssert(result1.0 == 4)
        XCTAssert(result1.1.isEmpty)
        
        let example2 = "())()"
        let result2 = dyckParser.parse(example2)
        XCTAssert(result2.0 == 1)
        XCTAssert(result2.1.startIndex == example2.index(example2.startIndex, offsetBy: 3))
    }
}
