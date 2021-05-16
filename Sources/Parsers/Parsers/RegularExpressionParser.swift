import Foundation

public struct RegularExpressionParser: Parser {
    public typealias Stream = String
    public typealias Output = (stream: String, match: NSTextCheckingResult)
    public enum Failure: Error {
        case noMatch
    }
    
    private let e: NSRegularExpression
    private let options: NSRegularExpression.MatchingOptions
    
    public init(_ e: NSRegularExpression, options: NSRegularExpression.MatchingOptions = .anchored) {
        self.e = e
        self.options = options
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            if let match = e.firstMatch(in: stream, options: options, range: NSRange(index..., in: stream)) {
                // Force unwrap is okay since this NSRange was given to us by Foundation
                let range = Range(match.range, in: stream)!
                return .success(((stream, match), range.upperBound))
            } else {
                return .failure(.noMatch)
            }
        }
    }
}
