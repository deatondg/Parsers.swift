public struct FlatMapParser<P: Parser, MapParser: Parser, MapFailure: Error>: Parser where MapParser.Stream == P.Stream {
    public typealias Stream = P.Stream
    public typealias Output = MapParser.Output
    public enum Failure: Error {
        case outerFailure(P.Failure)
        case mapFailure(MapFailure)
        case innerFailure(MapParser.Failure)
    }
    
    private let p: P
    private let f: (P.Output) -> Result<MapParser, MapFailure>
    
    public init(_ p: P, _ f: @escaping (P.Output) -> Result<MapParser, MapFailure>) {
        self.p = p
        self.f = f
    }
    public init(_ p: P, _ f: @escaping (P.Output) throws -> MapParser) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    public init(_ p: P, _ f: @escaping (P.Output) -> MapParser) where MapFailure == Never {
        self.p = p
        self.f = { return .success(f($0)) }
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let outerFailure):
                return .failure(.outerFailure(outerFailure))
            case .success(let (innerOutput, index)):
                switch f(innerOutput) {
                case .failure(let mapFailure):
                    return .failure(.mapFailure(mapFailure))
                case .success(let mapParser):
                    switch mapParser.parse(stream, index) {
                    case .failure(let innerFailure):
                        return .failure(.innerFailure(innerFailure))
                    case .success(let (outerOutput, index)):
                        return .success((outerOutput, index))
                    }
                }
            }
            
        }
    }
}
public extension Parser {
    func flatMap<MapParser: Parser, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> FlatMapParser<Self, MapParser, MapFailure> where MapParser.Stream == Stream {
        .init(self, f)
    }
    func flatMap<MapParser: Parser>(_ f: @escaping (Output) throws -> MapParser) -> FlatMapParser<Self, MapParser, Error> where MapParser.Stream == Stream {
        .init(self, f)
    }
    func flatMap<MapParser: Parser>(_ f: @escaping (Output) -> MapParser) -> FlatMapParser<Self, MapParser, Never> where MapParser.Stream == Stream {
        .init(self, f)
    }
}
