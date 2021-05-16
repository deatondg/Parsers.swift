public struct FailableFlatFailableMapFailableParser<P: Parser, MapParser: Parser, MapFailure: Error>: Parser where MapParser.Stream == P.Stream {
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
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream in
            switch p.parse(stream) {
            case .failure(let outerFailure):
                return .failure(.outerFailure(outerFailure))
            case .success(let (innerOutput, stream)):
                switch f(innerOutput) {
                case .failure(let mapFailure):
                    return .failure(.mapFailure(mapFailure))
                case .success(let mapParser):
                    switch mapParser.parse(stream) {
                    case .failure(let innerFailure):
                        return .failure(.innerFailure(innerFailure))
                    case .success(let (outerOutput, stream)):
                        return .success((outerOutput, stream))
                    }
                }
            }
            
        }
    }
}
extension Parser {
    func flatMap<MapParser: Parser, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> FailableFlatFailableMapFailableParser<Self, MapParser, MapFailure> where MapParser.Stream == Stream {
        .init(self, f)
    }
    func flatMap<MapParser: Parser>(_ f: @escaping (Output) throws -> MapParser) -> FailableFlatFailableMapFailableParser<Self, MapParser, Error> where MapParser.Stream == Stream {
        .init(self, f)
    }
}
