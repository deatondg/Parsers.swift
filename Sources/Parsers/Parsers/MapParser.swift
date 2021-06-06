@frozen public enum MapParserFailure<ParseFailure: Error, MapFailure: Error>: Error {
    case parseFailure(ParseFailure)
    case mapFailure(MapFailure)
}
public struct MapParser<P: Parser, MapOutput, MapFailure: Error>: Parser {
    public typealias Stream = P.Stream
    public typealias Output = MapOutput
    public typealias Failure = MapParserFailure<P.Failure, MapFailure>
    
    private let p: P
    private let f: (P.Output) -> Result<MapOutput, MapFailure>
    
    public init(_ p: P, _ f: @escaping (P.Output) -> Result<MapOutput, MapFailure>) {
        self.p = p
        self.f = f
    }
    public init(_ p: P, _ f: @escaping (P.Output) throws -> MapOutput) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    public init(_ p: P, _ f: @escaping (P.Output) -> MapOutput) where MapFailure == Never {
        self.p = p
        self.f = { .success(f($0)) }
    }
    public init(_ p: P, replaceOutputsWith o: MapOutput) where MapFailure == Never {
        self.p = p
        self.f = { _ in .success(o) }
    }
    
    public var parse: PrimitiveParser<Stream, MapOutput, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let parseFailure):
                return .failure(.parseFailure(parseFailure))
            case .success(let (parseOutput, index)):
                switch f(parseOutput) {
                case .failure(let mapFailure):
                    return .failure(.mapFailure(mapFailure))
                case .success(let mapOutput):
                    return .success((mapOutput, index))
                }
            }
        }
    }
}
public extension Parser {
    func map<MapOutput, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapOutput, MapFailure>) -> MapParser<Self, MapOutput, MapFailure> {
        .init(self, f)
    }
    func map<MapOutput>(_ f: @escaping (Output) throws -> MapOutput) -> MapParser<Self, MapOutput, Error> {
        .init(self, f)
    }
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> MapParser<Self, MapOutput, Never> {
        .init(self, f)
    }
}
public extension Parser {
    func replaceOutputs<MapOutput>(with o: MapOutput) -> MapParser<Self, MapOutput, Never> {
        .init(self, replaceOutputsWith: o)
    }
    func ignoreOutputs() -> MapParser<Self, (), Never> {
        .init(self, replaceOutputsWith: ())
    }
}
