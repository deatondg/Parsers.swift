struct FailParser<Failure: Error>: ParserProtocol {
    typealias Output = Never
    
    let f: Failure
    
    init(_ f: Failure) {
        self.f = f
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Never, endIndex: String.Index), Failure> {
            .failure(f)
    }
}

public extension Parsers {
    static func fail<Failure: Error>(_ f: Failure) -> Parser<Never, Failure> {
        FailParser(f).eraseToParser()
    }
}
