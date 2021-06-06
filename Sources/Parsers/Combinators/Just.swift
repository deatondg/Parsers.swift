struct JustParser<Stream: Collection, Output>: ParserProtocol {
    typealias Failure = Never
    
    let v: Output
    
    init(_ v: Output) {
        self.v = v
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Never> {
        .success((v, index))
    }
}

public extension Parser {
    static func just(_ v: Output) -> Self where Failure == Never {
        JustParser(v).parser
    }
}
