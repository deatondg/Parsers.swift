struct PrefixParser<Stream: Collection, PossiblePrefix: Collection>: ParserProtocol where Stream.Element: Equatable, PossiblePrefix.Element == Stream.Element {
    typealias Output = Stream.SubSequence
    typealias Failure = NoMatchFailure
    
    let p: PossiblePrefix
    
    init(_ p: PossiblePrefix) {
        self.p = p
    }
    init(_ p: Stream.Element) where PossiblePrefix == CollectionOfOne<Stream.Element> {
        self.p = CollectionOfOne(p)
    }
    
    func parse(from stream: Stream, startingAt startIndex: Stream.Index) -> Result<(value: Stream.SubSequence, endIndex: Stream.Index), NoMatchFailure> {
        if stream[startIndex...].starts(with: p) {
            let endIndex = stream.index(startIndex, offsetBy: p.count)
            return .success((stream[startIndex..<endIndex], endIndex))
        } else {
            return .failure(.noMatch)
        }
    }
}

public extension Parsers where Stream.Element: Equatable {
    static func prefix<PossiblePrefix: Collection>(_ p: PossiblePrefix) -> Parser<Stream, Stream.SubSequence, NoMatchFailure> where PossiblePrefix.Element == Stream.Element {
        PrefixParser(p).parser
    }
    static func prefix(_ p: Stream.Element) -> Parser<Stream, Stream.SubSequence, NoMatchFailure> {
        PrefixParser(p).parser
    }
}
