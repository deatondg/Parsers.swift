public struct FlatFailableMapParser<P: Parser, MapParser: Parser, MapFailure: Error>: Parser where MapParser.Stream == P.Stream, P.Failure == Never, MapParser.Failure == Never {
    public typealias Stream = P.Stream
    public typealias Output = MapParser.Output
    public typealias Failure = MapFailure
    
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
        return { stream, index in
            switch p.parse(stream, index) {
            // Cannot fail
            case .success(let (innerOutput, index)):
                switch f(innerOutput) {
                case .failure(let mapFailure):
                    return .failure(mapFailure)
                case .success(let mapParser):
                    switch mapParser.parse(stream, index) {
                    // Cannot fail
                    case .success(let (outerOutput, index)):
                        return .success((outerOutput, index))
                    }
                }
            }
            
        }
    }
}
extension Parser {
    func flatMap<MapParser: Parser, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> FlatFailableMapParser<Self, MapParser, MapFailure> where MapParser.Stream == Stream, Failure == Never, MapParser.Failure == Never {
        .init(self, f)
    }
    func flatMap<MapParser: Parser>(_ f: @escaping (Output) throws -> MapParser) -> FlatFailableMapParser<Self, MapParser, Error> where MapParser.Stream == Stream, Failure == Never, MapParser.Failure == Never {
        .init(self, f)
    }
}
