struct PrefixParser<PossiblePrefix: Collection>: ParserProtocol where PossiblePrefix.Element == Character {
    typealias Output = Substring
    typealias Failure = NoMatchFailure
    
    let p: PossiblePrefix
    
    init(_ p: PossiblePrefix) {
        self.p = p
    }
    init(_ p: Character) where PossiblePrefix == CollectionOfOne<Character> {
        self.p = CollectionOfOne(p)
    }
    
    func parse(from string: String, startingAt startIndex: String.Index) -> Result<(value: Substring, endIndex: String.Index), NoMatchFailure> {
        if string[startIndex...].starts(with: p) {
            let endIndex = string.index(startIndex, offsetBy: p.count)
            return .success((string[startIndex..<endIndex], endIndex))
        } else {
            return .failure(.noMatch)
        }
    }
}

public extension Parsers {
    static func prefix<PossiblePrefix: Collection>(_ p: PossiblePrefix) -> Parser<Substring, NoMatchFailure> where PossiblePrefix.Element == Character {
        PrefixParser(p).eraseToParser()
    }
    static func prefix(_ p: Character) -> Parser<Substring, NoMatchFailure> {
        PrefixParser(p).eraseToParser()
    }
}

extension Collection where Element == Character {
    func prefixParser() -> Parser<Substring, NoMatchFailure> {
        Parsers.prefix(self)
    }
}
extension Character {
    func prefixParser() -> Parser<Substring, NoMatchFailure> {
        Parsers.prefix(self)
    }
}
