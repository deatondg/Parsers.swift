public struct FailableFlattenParser<P: Parser>: Parser where P.Output: Parser, P.Output.Stream == P.Stream, P.Failure == Never {
    public typealias Stream = P.Stream
    public typealias Output = P.Output.Output
    public typealias Failure = P.Output.Failure
    
    private let p: P
    
    public init(_ p: P) {
        self.p = p
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream in
            switch p.parse(stream) {
            // Cannot fail
            case .success(let (outerOutput, stream)):
                switch outerOutput.parse(stream) {
                case .failure(let innerFailure):
                    return .failure(innerFailure)
                case .success(let (innerOutput, stream)):
                    return .success((innerOutput, stream))
                }
            }
        }
    }
}
public extension Parser where Output: Parser, Output.Stream == Stream {
    func flatten() -> FailableFlattenParser<Self> where Failure == Never {
        .init(self)
    }
}
