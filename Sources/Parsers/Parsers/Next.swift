struct NextParser: ParserProtocol {
    typealias Output = String.Element
    typealias Failure = EmptyFailure
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: String.Element, endIndex: String.Index), EmptyFailure> {
        if string.indices.contains(index) {
            return .success((string[index], string.index(after: index)))
        } else {
            return .failure(.empty)
        }
    }
}

public extension Parsers {
    static func next() -> Parser<String.Element, EmptyFailure> {
        NextParser().parser
    }
}
