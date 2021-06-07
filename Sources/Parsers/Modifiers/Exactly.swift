@frozen
public enum ExactlyParserFailure<ParseOutput, ParseFailure: Error>: Error {
    case parseFailure(ParseFailure)
    case unconsumedInput(output: ParseOutput, endIndex: String.Index)
}

struct ExactlyParser<Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = ExactlyParserFailure<Output, ParseFailure>
    
    let p: Parser<Output, ParseFailure>
    
    init(_ p: Parser<Output, ParseFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), ExactlyParserFailure<Output, ParseFailure>> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let parseFailure):
            return .failure(.parseFailure(parseFailure))
        case .success(let (parseOutput, index)):
            guard index == string.endIndex else {
                return .failure(.unconsumedInput(output: parseOutput, endIndex: index))
            }
            return .success((parseOutput, index))
        }
    }
}

public extension Parser {
    func exactly() -> Parser<Output, ExactlyParserFailure<Output, Failure>> {
        ExactlyParser(self).eraseToParser()
    }
}
