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
    
    public init(_ p: P, replaceOutputsWith o: MapOutput) {
        self.p = p
        self.f = { _ in o }
    }

    public var parse: PrimitiveParser<Stream, MapOutput, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
            case .failure(let parseFailure):
                return .failure(parseFailure)
            case .success(let (parseOutput, index)):
                return .success((f(parseOutput), index))
            }
        }
    }
}
public extension Parser {
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> MapFailableParser<Self, MapOutput> {
        .init(self, f)
    }
}
public extension Parser {
    func replaceOutputs<MapOutput>(with o: MapOutput) -> MapFailableParser<Self, MapOutput> {
        .init(self, replaceOutputsWith: o)
    }
    func ignoreOutputs() -> MapFailableParser<Self, ()> {
        .init(self, replaceOutputsWith: ())
    }
}
