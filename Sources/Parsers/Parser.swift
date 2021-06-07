public typealias PrimitiveParser<Output, Failure: Error> = (String, String.Index) -> Result<(value: Output, endIndex: String.Index), Failure>

public struct Parser<Output, Failure: Error>: ParserProtocol {
    private let primitiveParser: PrimitiveParser<Output, Failure>
    
    public func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        self.primitiveParser(string, index)
    }
    public var parser: Parser<Output, Failure> { self }
    
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

//@dynamicMemberLookup
public protocol ParserProtocol {
    associatedtype Output
    associatedtype Failure: Error
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure>
    
    @ParserBuilder
    var parser: Parser<Output, Failure> { get }
    
//    subscript<T>(dynamicMember dynamicMember: KeyPath<Parser<Output, Failure>, T>) -> T { get }
}
public extension ParserProtocol {
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        self.parser.parse(from: string, startingAt: index)
    }
    
    var parser: Parser<Output, Failure> {
        Parser(__primitiveParser: self.parse)
    }
    
//    subscript<T>(dynamicMember keyPath: KeyPath<Parser<Output, Failure>, T>) -> T {
//        self.parser[keyPath: keyPath]
//    }
}
public extension ParserProtocol {
    func parse(from string: String, startingAt index: String.Index) -> (value: Output, endIndex: String.Index) where Failure == Never {
        self.parse(from: string, startingAt: index).get()
    }
    func parse(from string: String, startingAt index: String.Index) throws -> (value: Output, endIndex: String.Index) {
        try self.parse(from: string, startingAt: index).get()
    }
}

public extension ParserProtocol {
    func parse(from string: String) -> Result<(value: Output, endIndex: String.Index), Failure> {
        self.parse(from: string, startingAt: string.startIndex)
    }
    func parse(from string: String) -> (value: Output, endIndex: String.Index) where Failure == Never {
        self.parse(from: string).get()
    }
    func parse(from string: String) throws -> (value: Output, endIndex: String.Index) {
        try self.parse(from: string).get()
    }
}
