public struct FlatCatchParser<P: Parser, CatchParser: Parser, CatchFailure: Error>: Parser where CatchParser.Stream == P.Stream, CatchParser.Output == P.Output {
    public typealias Stream = P.Stream
    public typealias Output = P.Output
    public enum Failure: Error {
        case catchFailure(CatchFailure)
        case parseFailure(CatchParser.Failure)
    }
    
    private let p: P
    private let c: (P.Failure) -> Result<CatchParser, CatchFailure>
    
    public init(_ p: P, _ c: @escaping (P.Failure) -> Result<CatchParser, CatchFailure>) {
        self.p = p
        self.c = c
    }
    public init(_ p: P, _ c: @escaping (P.Failure) throws -> CatchParser) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    public init(_ p: P, _ c: @escaping (P.Failure) -> CatchParser) where CatchFailure == Never {
        self.p = p
        self.c = { .success(c($0)) }
    }
    public init(_ p: P, _ c: CatchParser) {
        self.p = p
        self.c = { _ in .success(c) }
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let outerFailure):
                switch c(outerFailure) {
                case .failure(let catchFailure):
                    return .failure(.catchFailure(catchFailure))
                case .success(let catchParser):
                    switch catchParser.parse(stream, index) {
                    case .failure(let parseFailure):
                        return .failure(.parseFailure(parseFailure))
                    case .success(let (catchOutput, index)):
                        return .success((catchOutput, index))
                    }
                }
            case .success(let (output, index)):
                return .success((output, index))
            }
        }
    }
}
public extension Parser {
    func `catch`<CatchParser: Parser, CatchFailure: Error>(_ c: @escaping (Failure) -> Result<CatchParser, CatchFailure>) -> FlatCatchParser<Self, CatchParser, CatchFailure> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
    func `catch`<CatchParser: Parser>(_ c: @escaping (Failure) throws -> CatchParser) -> FlatCatchParser<Self, CatchParser, Error> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
    func `catch`<CatchParser: Parser>(_ c: @escaping (Failure) -> CatchParser) -> FlatCatchParser<Self, CatchParser, Never> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
    func `catch`<CatchParser: Parser>(_ c: CatchParser) -> FlatCatchParser<Self, CatchParser, Never> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
}
