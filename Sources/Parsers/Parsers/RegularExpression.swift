import Foundation

struct RegularExpressionPrefixParser: ParserProtocol {
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

extension NSRegularExpression: UsableInParserBuilder {
    public typealias ParserBuilderOutput = RegularExpressionMatch
    public typealias ParserBuilderFailure = NoMatchFailure
    
    public func prefixParser() -> Parser<RegularExpressionMatch, NoMatchFailure> {
        RegularExpressionPrefixParser(self).eraseToParser()
    }
    public func nextMatchParser() -> Parser<(prefix: Substring, match: RegularExpressionMatch), NoMatchFailure> {
        RegularExpressionNextMatchParser(self).eraseToParser()
    }
    
    public func parserForBuilder() -> Parser<RegularExpressionMatch, NoMatchFailure> {
        self.prefixParser()
    }
}
