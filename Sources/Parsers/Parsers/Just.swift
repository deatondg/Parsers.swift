struct JustParser<Output>: ParserProtocol {
    typealias Failure = Never
    
    let v: Output
    
    init(_ v: Output) {
        self.v = v
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Never> {
        .success((v, index))
    }
}

public extension Parsers {
    static func just<Output>(_ v: Output) -> Parser<Output, Never> {
        JustParser(v).parser
    }
}
