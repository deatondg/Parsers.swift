public struct FailableFlattenFailableParser<P: Parser>: Parser where P.Output: Parser, P.Output.Stream == P.Stream {
    public typealias Stream = P.Stream
    public typealias Output = P.Output.Output
    public enum Failure: Error {
        case outerFailure(P.Failure)
        case innerFailure(P.Output.Failure)
    }
    
    private let p: P
    
    public init(_ p: P) {
        self.p = p
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream in
            switch p.parse(stream) {
            case .failure(let outerFailure):
                return .failure(.outerFailure(outerFailure))
            case .success(let (outerOutput, stream)):
                switch outerOutput.parse(stream) {
                case .failure(let innerFailure):
                    return .failure(.innerFailure(innerFailure))
                case .success(let (innerOutput, stream)):
                    return .success((innerOutput, stream))
                }
            }
        }
    }
}
public extension Parser where Output: Parser, Output.Stream == Stream {
    func flatten() -> FailableFlattenFailableParser<Self> {
        .init(self)
    }
}
