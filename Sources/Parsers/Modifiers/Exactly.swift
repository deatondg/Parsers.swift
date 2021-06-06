@frozen
public enum ExactlyParserFailure<Stream: Collection, ParseFailure: Error>: Error {
    case parseFailure(ParseFailure)
    case unconsumedInput(Stream.Index)
}

struct ExactlyParser<Stream: Collection, Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = ExactlyParserFailure<Stream, ParseFailure>
    
    let p: Parser<Stream, Output, ParseFailure>
    
    init(_ p: Parser<Stream, Output, ParseFailure>) {
        self.p = p
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), ExactlyParserFailure<Stream, ParseFailure>> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let parseFailure):
            return .failure(.parseFailure(parseFailure))
        case .success(let (parseOutput, index)):
            guard index == stream.endIndex else {
                return .failure(.unconsumedInput(index))
            }
            return .success((parseOutput, index))
        }
    }
}

public extension Parser {
    func exactly() -> Parser<Stream, Output, ExactlyParserFailure<Stream, Failure>> {
        ExactlyParser(self).parser
    }
}
