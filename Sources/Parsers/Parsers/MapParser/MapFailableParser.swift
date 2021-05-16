public struct MapFailableParser<P: Parser, MapOutput>: Parser {
    public typealias Stream = P.Stream
    public typealias Output = MapOutput
    public typealias Failure = P.Failure
    
    private let p: P
    private let f: (P.Output) -> MapOutput
    
    public init(_ p: P, _ f: @escaping (P.Output) -> MapOutput) {
        self.p = p
        self.f = f
    }

    public var parse: PrimitiveParser<Stream, MapOutput, Failure> {
        return { stream in
            switch p.parse(stream) {
            case .failure(let parseFailure):
                return .failure(parseFailure)
            case .success(let (parseOutput, stream)):
                return .success((f(parseOutput), stream))
            }
        }
    }
}
public extension Parser {
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> MapFailableParser<Self, MapOutput> {
        .init(self, f)
    }
}
