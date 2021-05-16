public struct FlattenFailableParser<P: Parser>: Parser where P.Output: Parser, P.Output.Stream == P.Stream, P.Output.Failure == Never {
    public typealias Stream = P.Stream
    public typealias Output = P.Output.Output
    public typealias Failure = P.Failure
    
    private let p: P
    
    public init(_ p: P) {
        self.p = p
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let outerFailure):
                return .failure(outerFailure)
            case .success(let (outerOutput, index)):
                switch outerOutput.parse(stream, index) {
                // Cannot fail
                case .success(let (innerOutput, index)):
                    return .success((innerOutput, index))
                }
            }
        }
    }
}
public extension Parser where Output: Parser, Output.Stream == Stream, Output.Failure == Never {
    func flatten() -> FlattenFailableParser<Self> {
        .init(self)
    }
}
