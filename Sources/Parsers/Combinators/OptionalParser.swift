extension Optional: Error where Wrapped: Error {}

struct ParseOrFailParser<Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = ParseFailure?
    
    let p: Parser<Output, ParseFailure>?
    
    init(_ p: Parser<Output, ParseFailure>?) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        if let p = p {
            switch p.parse(from: string, startingAt: index) {
            case .success(let (output, index)):
                return .success((output, index))
            case .failure(let failure):
                return .failure(failure)
            }
        } else {
            return .failure(nil)
        }
    }
}

public extension Optional where Wrapped: ParserProtocol {
    func orFailParser() -> Parser<Wrapped.Output, Wrapped.Failure?> {
        ParseOrFailParser(self?.eraseToParser()).eraseToParser()
    }
}
