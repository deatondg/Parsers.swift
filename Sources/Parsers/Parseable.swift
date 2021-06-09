public protocol Parsable {
    associatedtype ParseFailure: Error
    
    static func parse(from string: String, startingAt index: String.Index) -> Result<(value: Self, endIndex: String.Index), ParseFailure>
}

public protocol ParsableFromBuilder: Parsable {
    static var parser: Parser<Self, ParseFailure> { get }
}
extension ParsableFromBuilder {
    static func parse(from string: String, startingAt index: String.Index) -> Result<(value: Self, endIndex: String.Index), ParseFailure> {
        Self.parser.parse(from: string, startingAt: index)
    }
}

extension Parsers {
    static func of<P: Parsable>(_ p: P.Type) -> Parser<P, P.ParseFailure> {
        Parser(__primitiveParser: P.parse)
    }
}
