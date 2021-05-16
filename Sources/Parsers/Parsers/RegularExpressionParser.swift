import Foundation

public struct RegularExpressionParser: Parser {
    public typealias Stream = String
    public typealias Output = (String, NSTextCheckingResult)
    public enum Failure: Error {
        case noMatch
    }
    
    private let e: NSRegularExpression
    
    public init(_ e: NSRegularExpression) {
        self.e = e
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream in
            fatalError()
            //if let e.matches(in: <#T##String#>, options: <#T##NSRegularExpression.MatchingOptions#>, range: <#T##NSRange#>)
        }
    }
}
