public typealias PrimitiveParser<Output, Failure: Error> = (String, String.Index) -> Result<(value: Output, endIndex: String.Index), Failure>

public struct Parser<Output, Failure: Error>: ParserProtocol {
    private let primitiveParser: PrimitiveParser<Output, Failure>
    
    public func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        self.primitiveParser(string, index)
    }
    
    public func eraseToParser() -> Parser<Output, Failure> { self }
    
    public var parserForBuilder: Parser<Output, Failure> { self }
    
    // TODO: Update this API
    init(__primitiveParser: @escaping PrimitiveParser<Output, Failure>) {
        self.primitiveParser = __primitiveParser
    }
    /*
    public init<P: ParserProtocol>(_ parser: P) where P.Output == Output, P.Failure == Failure {
        self.primitiveParser = parser.parse
    }
    public init(_ parse: @autoclosure @escaping () -> PrimitiveParser<String, Output, Failure>) {
        self.parse = { string, index in parse()(string, index) }
    }
    public init(eager parse: @escaping PrimitiveParser<String, Output, Failure>) {
        self.parse = parse
    }
    
    public init<P: Parser>(_ p: P) where P.String == String, P.Output == Output, P.Failure == Failure {
        self.parse = { string, index in p.parse(string, index) }
    }
    public init<P: Parser>(eager p: P) where P.String == String, P.Output == Output, P.Failure == Failure {
        self.parse = p.parse
    }
    */
}

