public struct FailableMapParser<P: Parser, MapOutput, MapFailure: Error>: Parser where P.Failure == Never {
    public typealias Stream = P.Stream
    public typealias Output = MapOutput
    public typealias Failure = MapFailure
    
    private let p: P
    private let f: (P.Output) -> Result<MapOutput, MapFailure>
    
    public init(_ p: P, _ f: @escaping (P.Output) -> Result<MapOutput, MapFailure>) {
        self.p = p
        self.f = f
    }
    public init(_ p: P, _ f: @escaping (P.Output) throws -> MapOutput) where MapFailure == Error {
        self.p = p
        self.f = { parseOutput in
            do {
                let mapOutput = try f(parseOutput)
                return .success(mapOutput)
            } catch {
                return .failure(error)
            }
        }
    }
    
    public var parse: PrimitiveParser<Stream, MapOutput, Failure> {
        return { stream in
            switch p.parse(stream) {
            // Cannot fail
            case .success(let (parseOutput, stream)):
                switch f(parseOutput) {
                case .failure(let mapFailure):
                    return .failure(mapFailure)
                case .success(let mapOutput):
                    return .success((mapOutput, stream))
                }
            }
        }
    }
}
public extension Parser {
    func map<MapOutput, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapOutput, MapFailure>) -> FailableMapParser<Self, MapOutput, MapFailure> where Failure == Never {
        .init(self, f)
    }
    func map<MapOutput>(_ f: @escaping (Output) throws -> MapOutput) -> FailableMapParser<Self, MapOutput, Error> where Failure == Never {
        .init(self, f)
    }
}
