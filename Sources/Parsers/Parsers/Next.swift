struct NextParser<Stream: Collection>: ParserProtocol {
    typealias Output = Stream.Element
    typealias Failure = EmptyFailure
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Stream.Element, endIndex: Stream.Index), EmptyFailure> {
        if stream.indices.contains(index) {
            return .success((stream[index], stream.index(after: index)))
        } else {
            return .failure(.empty)
        }
    }
}

public extension Parsers {
    static func next() -> Parser<Stream, Stream.Element, EmptyFailure> {
        NextParser().parser
    }
}
