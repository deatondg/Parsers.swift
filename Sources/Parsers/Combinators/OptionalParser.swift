@frozen
public enum OptionalFailure<Failure: Error>: Error, ExpressibleByNilLiteral {
    case none
    case failure(Failure)

    public init(nilLiteral: ()) {
        self = .none
    }
    public init(_ failure: Failure?) {
        self = failure.map(OptionalFailure.failure) ?? .none
    }
    
    var failure: Failure? {
        switch self {
        case .none:
            return nil
        case .failure(let failure):
            return failure
        }
    }
}

struct ParseOrFailParser<Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = OptionalFailure<ParseFailure>
    
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
                return .failure(.failure(failure))
            }
        } else {
            return .failure(nil)
        }
    }
}

public extension Optional where Wrapped: ParserProtocol {
    func orFailParser() -> Parser<Wrapped.Output, OptionalFailure<Wrapped.Failure>> {
        ParseOrFailParser(self?.eraseToParser()).eraseToParser()
    }
}
