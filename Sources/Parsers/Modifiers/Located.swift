public struct Located<T> {
    public let value: T
    public let index: String.Index
    
    public init(value: T, index: String.Index) {
        self.value = value
        self.index = index
    }
}
extension Located: Error where T: Error {}

struct LocatedFailuresParser<Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = Located<ParseFailure>
    
    let p: Parser<Output, ParseFailure>
    
    init(_ p: Parser<Output, ParseFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Located<ParseFailure>> {
        switch p.parse(from: string, startingAt: index) {
        case .success(let (output, index)):
            return .success((output, index))
        case .failure(let failure):
            return .failure(.init(value: failure, index: index))
        }
    }
}
public extension ParserProtocol {
    func locatingFailures() -> Parser<Output, Located<Failure>> {
        LocatedFailuresParser(self.eraseToParser()).eraseToParser()
    }
}
// TODO: Add the other parsers
