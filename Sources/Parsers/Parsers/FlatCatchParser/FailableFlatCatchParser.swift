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
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream in
            switch p.parse(stream) {
            case .failure(let outerFailure):
                switch c(outerFailure).parse(stream) {
                case .failure(let parseFailure):
                    return .failure(parseFailure)
                case .success(let (catchOutput, stream)):
                    return .success((catchOutput, stream))
                }
            case .success(let (output, stream)):
                return .success((output, stream))
            }
        }
    }
}
extension Parser {
    func `catch`<CatchParser: Parser>(_ c: @escaping (Failure) -> CatchParser) -> FailableFlatCatchParser<Self, CatchParser> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        .init(self, c)
    }
}
