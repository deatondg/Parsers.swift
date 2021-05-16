public struct FailableFlatMapParser<P: Parser, MapParser: Parser>: Parser where MapParser.Stream == P.Stream, P.Failure == Never {
    public typealias Stream = P.Stream
    public typealias Output = MapParser.Output
    public typealias Failure = MapParser.Failure
    
    private let p: P
    private let f: (P.Output) -> MapParser
    
    public init(_ p: P, _ f: @escaping (P.Output) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            // Cannot fail
            case .success(let (innerOutput, index)):
                switch f(innerOutput).parse(stream, index) {
                case .failure(let innerFailure):
                    return .failure(innerFailure)
                case .success(let (outerOutput, index)):
                    return .success((outerOutput, index))
                }
            }
            
        }
    }
}
extension Parser {
    func flatMap<MapParser: Parser>(_ f: @escaping (Output) -> MapParser) -> FailableFlatMapParser<Self, MapParser> where MapParser.Stream == Stream, Failure == Never {
        .init(self, f)
    }
}
