public typealias PrimitiveParser<Stream: Collection, Output, Failure: Error> = (Stream, Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Failure>

public struct Parser<Stream: Collection, Output, Failure: Error>: ParserProtocol {
    private let primitiveParser: PrimitiveParser<Stream, Output, Failure>
    
    public func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Failure> {
        self.primitiveParser(stream, index)
    }
    public var parser: Parser<Stream, Output, Failure> { self }
    
    init(__primitiveParser: @escaping PrimitiveParser<Stream, Output, Failure>) {
        self.primitiveParser = __primitiveParser
    }
    
    public init<P: ParserProtocol>(_ parser: P) where P.Stream == Stream, P.Output == Output, P.Failure == Failure {
        self.primitiveParser = parser.parse
    }
    /*
    public init(_ parse: @autoclosure @escaping () -> PrimitiveParser<Stream, Output, Failure>) {
        self.parse = { stream, index in parse()(stream, index) }
    }
    public init(eager parse: @escaping PrimitiveParser<Stream, Output, Failure>) {
        self.parse = parse
    }
    
    public init<P: Parser>(_ p: P) where P.Stream == Stream, P.Output == Output, P.Failure == Failure {
        self.parse = { stream, index in p.parse(stream, index) }
    }
    public init<P: Parser>(eager p: P) where P.Stream == Stream, P.Output == Output, P.Failure == Failure {
        self.parse = p.parse
    }
    */
}

@dynamicMemberLookup
public protocol ParserProtocol {
    associatedtype Stream: Collection
    associatedtype Output
    associatedtype Failure: Error
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Failure>
    
    @ParserBuilder
    var parser: Parser<Stream, Output, Failure> { get }
    
    subscript<T>(dynamicMember dynamicMember: KeyPath<Parser<Stream, Output, Failure>, T>) -> T { get }
}
public extension ParserProtocol {
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Failure> {
        self.parser.parse(from: stream, startingAt: index)
    }
    
    var parser: Parser<Stream, Output, Failure> {
        Parser(__primitiveParser: self.parse)
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Parser<Stream, Output, Failure>, T>) -> T {
        self.parser[keyPath: keyPath]
    }
}
public extension ParserProtocol {
    func parse(from stream: Stream, startingAt index: Stream.Index) -> (value: Output, endIndex: Stream.Index) where Failure == Never {
        self.parse(from: stream, startingAt: index).get()
    }
    func parse(from stream: Stream, startingAt index: Stream.Index) throws -> (value: Output, endIndex: Stream.Index) {
        try self.parse(from: stream, startingAt: index).get()
    }
}

public extension ParserProtocol {
    func parse(from stream: Stream) -> Result<(value: Output, endIndex: Stream.Index), Failure> {
        self.parse(from: stream, startingAt: stream.startIndex)
    }
    func parse(from stream: Stream) -> (value: Output, endIndex: Stream.Index) where Failure == Never {
        self.parse(from: stream).get()
    }
    func parse(from stream: Stream) throws -> (value: Output, endIndex: Stream.Index) {
        try self.parse(from: stream).get()
    }
}
