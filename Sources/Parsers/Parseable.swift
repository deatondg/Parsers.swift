public protocol Parseable {
    associatedtype ParseFailure: Error
    
    static func parse(from string: String, startingAt index: String.Index) -> Result<(value: Self, endIndex: String.Index), ParseFailure>
}

public protocol ParseableFromBuilder: Parseable {
    static var parser: Parser<Self, ParseFailure> { get }
}
extension ParseableFromBuilder {
    static func parse(from string: String, startingAt index: String.Index) -> Result<(value: Self, endIndex: String.Index), ParseFailure> {
        Self.parser.parse(from: string, startingAt: index)
    }
}

extension Parsers {
    static func `for`<P: Parseable>(_ p: P.Type) -> Parser<P, P.ParseFailure> {
        Parser(__primitiveParser: P.parse)
    }
}
