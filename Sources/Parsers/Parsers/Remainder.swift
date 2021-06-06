struct RemainderParser<Stream: Collection>: ParserProtocol {
    typealias Output = Stream.SubSequence
    typealias Failure = Never
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Stream.SubSequence, endIndex: Stream.Index), Never> {
        return .success((stream[index...], stream.endIndex))
    }
}

public extension Parsers {
    static func remainder() -> Parser<Stream, Stream.SubSequence, Never> {
        RemainderParser().parser
    }
}
