public struct JustParser<Stream: Collection, Output>: Parser {
    public typealias Failure = Never
    
    private let v: Output
    
    public init(_ v: Output) {
        self.v = v
    }
    public init(_ v: Output, stream: Stream.Type) {
        self.v = v
    }
    
    public var parse: PrimitiveParser<Stream, Output, Never> {
        return { stream, startIndex in
            .success((v, startIndex))
        }
    }
}
public extension Parsers {
    static func just<Stream: Collection, Output>(_ v: Output) -> JustParser<Stream, Output> {
        .init(v)
    }
    static func just<Stream: Collection, Output>(_ v: Output, stream: Stream.Type) -> JustParser<Stream, Output> {
        .init(v)
    }
}
