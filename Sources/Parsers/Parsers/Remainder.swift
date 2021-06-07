struct RemainderParser: ParserProtocol {
    typealias Output = Substring
    typealias Failure = Never
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Substring, endIndex: String.Index), Never> {
        return .success((string[index...], string.endIndex))
    }
}

public extension Parsers {
    static func remainder() -> Parser<Substring, Never> {
        RemainderParser().eraseToParser()
    }
}
