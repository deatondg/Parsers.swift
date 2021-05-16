public struct AnyParser<Stream: Collection, Output, Failure: Error>: Parser {
    public let parse: PrimitiveParser<Stream, Output, Failure>
    
    public init(_ parse: @autoclosure @escaping () -> PrimitiveParser<Stream, Output, Failure>) {
        self.parse = { stream, startIndex in parse()(stream, startIndex) }
    }
    public init(eager parse: @escaping PrimitiveParser<Stream, Output, Failure>) {
        self.parse = parse
    }
    
    public init<P: Parser>(_ p: P) where P.Stream == Stream, P.Output == Output, P.Failure == Failure {
        self.parse = { stream, startIndex in p.parse(stream, startIndex) }
    }
    public init<P: Parser>(eager p: P) where P.Stream == Stream, P.Output == Output, P.Failure == Failure {
        self.parse = p.parse
    }
}

public extension Parser {
    func eraseToAnyParser(eager: Bool = false) -> AnyParser<Stream, Output, Failure> {
        if eager {
            return .init(eager: self)
        } else {
            return .init(self)
        }
    }
}
