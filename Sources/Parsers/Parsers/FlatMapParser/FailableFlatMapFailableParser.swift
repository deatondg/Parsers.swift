public struct FailableFlatMapFailableParser<P: Parser, MapParser: Parser>: Parser where MapParser.Stream == P.Stream {
    public typealias Stream = P.Stream
    public typealias Output = MapParser.Output
    public enum Failure: Error {
        case outerFailure(P.Failure)
        case innerFailure(MapParser.Failure)
    }
    
    private let p: P
    private let f: (P.Output) -> MapParser
    
    public init(_ p: P, _ f: @escaping (P.Output) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let outerFailure):
                return .failure(.outerFailure(outerFailure))
            case .success(let (innerOutput, index)):
                switch f(innerOutput).parse(stream, index) {
                case .failure(let innerFailure):
                    return .failure(.innerFailure(innerFailure))
                case .success(let (outerOutput, index)):
                    return .success((outerOutput, index))
                }
            }
            
        }
    }
}
extension Parser {
    func flatMap<MapParser: Parser>(_ f: @escaping (Output) -> MapParser) -> FailableFlatMapFailableParser<Self, MapParser> where MapParser.Stream == Stream {
        .init(self, f)
    }
}
