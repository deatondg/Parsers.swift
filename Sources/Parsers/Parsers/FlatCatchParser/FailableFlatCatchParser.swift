public struct FailableFlatCatchParser<P: Parser, CatchParser: Parser>: Parser where CatchParser.Stream == P.Stream, CatchParser.Output == P.Output {
    public typealias Stream = P.Stream
    public typealias Output = P.Output
    public typealias Failure = CatchParser.Failure
    
    private let p: P
    private let c: (P.Failure) -> CatchParser
    
    public init(_ p: P, _ c: @escaping (P.Failure) -> CatchParser) {
        self.p = p
        self.c = c
    }
    public init(_ p: P, _ c: CatchParser) {
        self.p = p
        self.c = { _ in c }
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let outerFailure):
                switch c(outerFailure).parse(stream, index) {
                case .failure(let parseFailure):
                    return .failure(parseFailure)
                case .success(let (catchOutput, index)):
                    return .success((catchOutput, index))
                }
            case .success(let (output, index)):
                return .success((output, index))
            }
        }
    }
}
extension Parser {
    func `catch`<CatchParser: Parser>(_ c: @escaping (Failure) -> CatchParser) -> FailableFlatCatchParser<Self, CatchParser> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
    func `catch`<CatchParser: Parser>(_ c: CatchParser) -> FailableFlatCatchParser<Self, CatchParser> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
}
