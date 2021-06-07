struct NextParser: ParserProtocol {
    typealias Output = Character
    typealias Failure = EmptyFailure
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Character, endIndex: String.Index), EmptyFailure> {
        if string.indices.contains(index) {
            return .success((string[index], string.index(after: index)))
        } else {
            return .failure(.empty)
        }
    }
}

public extension Parsers {
    static func next() -> Parser<Character, EmptyFailure> {
        NextParser().eraseToParser()
    }
}
