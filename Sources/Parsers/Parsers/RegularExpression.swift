import Foundation

struct RegularExpressionPrefixParser: ParserProtocol {
    typealias Stream = String
    typealias Output = RegularExpressionMatch
    typealias Failure = NoMatchFailure
    
    let e: NSRegularExpression
    
    init(_ e: NSRegularExpression) {
        self.e = e
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: RegularExpressionMatch, endIndex: String.Index), NoMatchFailure> {
        guard let match = e.firstMatch(in: string, options: .anchored, range: index...) else {
            return .failure(.noMatch)
        }
        return .success((match, match.range.upperBound))
    }
}

struct RegularExpressionNextMatchParser: ParserProtocol {
    typealias Stream = String
    typealias Output = (prefix: Substring, match: RegularExpressionMatch)
    typealias Failure = NoMatchFailure
    
    let e: NSRegularExpression
    
    init(_ e: NSRegularExpression) {
        self.e = e
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: (prefix: Substring, match: RegularExpressionMatch), endIndex: String.Index), NoMatchFailure> {
        guard let match = e.firstMatch(in: string, options: [], range: index...) else {
            return .failure(.noMatch)
        }
        return .success(( (string[index..<match.range.lowerBound], match), match.range.upperBound ))
    }
}

public extension NSRegularExpression {
    func prefixParser() -> Parser<String, RegularExpressionMatch, NoMatchFailure> {
        RegularExpressionPrefixParser(self).parser
    }
    func nextMatchParser() -> Parser<String, (prefix: Substring, match: RegularExpressionMatch), NoMatchFailure> {
        RegularExpressionNextMatchParser(self).parser
    }
}
