@resultBuilder
@frozen
public enum ParserBuilder {
    public static func buildExpression<P: ParserProtocol>(_ p: P) -> Parser<P.Stream, P.Output, P.Failure> {
        p.parser
    }
    public static func buildExpression<Stream: Collection, Output, Failure: Error>(_ p: @escaping PrimitiveParser<Stream, Output, Failure>) -> Parser<Stream, Output, Failure> {
        Parser(__primitiveParser: p)
    }
    public static func buildExpression<Stream: Collection, PossiblePrefix: Collection>(_ p: PossiblePrefix) -> Parser<Stream, Stream.SubSequence, NoMatchFailure> where Stream.Element: Equatable, PossiblePrefix.Element == Stream.Element {
        Parsers.prefix(p)
    }
    public static func buildExpression<Stream: Collection>(_ p: Stream.Element) -> Parser<Stream, Stream.SubSequence, NoMatchFailure> where Stream.Element: Equatable {
        Parsers.prefix(p)
    }
    
    public static func buildBlock<Stream: Collection, O0, F0: Error>(_ p0: Parser<Stream, O0, F0>) -> Parser<Stream, O0, F0> {
        p0
    }
    public static func buildBlock<Stream: Collection, O0, F0: Error, O1, F1: Error>(_ p0: Parser<Stream, O0, F0>, _ p1: Parser<Stream, O1, F1>) -> (Parser<Stream, O0, F0>, Parser<Stream, O1, F1>) {
        (p0, p1)
    }
    public static func buildBlock<Stream: Collection, O0, F0: Error, O1, F1: Error, O2, F2: Error>(_ p0: Parser<Stream, O0, F0>, _ p1: Parser<Stream, O1, F1>, _ p2: Parser<Stream, O2, F2>) -> (Parser<Stream, O0, F0>, Parser<Stream, O1, F1>, Parser<Stream, O2, F2>) {
        (p0, p1, p2)
    }
    public static func buildBlock<Stream: Collection, O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>(_ p0: Parser<Stream, O0, F0>, _ p1: Parser<Stream, O1, F1>, _ p2: Parser<Stream, O2, F2>, _ p3: Parser<Stream, O3, F3>) -> (Parser<Stream, O0, F0>, Parser<Stream, O1, F1>, Parser<Stream, O2, F2>, Parser<Stream, O3, F3>) {
        (p0, p1, p2, p3)
    }
}
