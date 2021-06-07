@resultBuilder
@frozen
public enum ParserBuilder {
    public static func buildExpression<Output, Failure: Error>(_ p: Parser<Output, Failure>) -> Parser<Output, Failure> {
        p
    }
    public static func buildExpression<P: ParserProtocol>(_ p: P) -> Parser<P.Output, P.Failure> {
        p.parser
    }
    public static func buildExpression<Output, Failure: Error>(_ p: @escaping PrimitiveParser<Output, Failure>) -> Parser<Output, Failure> {
        Parser(__primitiveParser: p)
    }
    public static func buildExpression<PossiblePrefix: Collection>(_ p: PossiblePrefix) -> Parser<Substring, NoMatchFailure> where PossiblePrefix.Element == Character {
        Parsers.prefix(p)
    }
    public static func buildExpression(_ p: Character) -> Parser<String.SubSequence, NoMatchFailure> {
        Parsers.prefix(p)
    }
    
    public static func buildBlock<O0, F0: Error>(_ p0: Parser<O0, F0>) -> Parser<O0, F0> {
        p0
    }
    public static func buildBlock<O0, F0: Error, O1, F1: Error>(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>) -> (Parser<O0, F0>, Parser<O1, F1>) {
        (p0, p1)
    }
    public static func buildBlock<O0, F0: Error, O1, F1: Error, O2, F2: Error>(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>, _ p2: Parser<O2, F2>) -> (Parser<O0, F0>, Parser<O1, F1>, Parser<O2, F2>) {
        (p0, p1, p2)
    }
    public static func buildBlock<O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>, _ p2: Parser<O2, F2>, _ p3: Parser<O3, F3>) -> (Parser<O0, F0>, Parser<O1, F1>, Parser<O2, F2>, Parser<O3, F3>) {
        (p0, p1, p2, p3)
    }
}
