@resultBuilder
@frozen
public enum ParserBuilder {
    public static func buildExpression<Output, Failure: Error>(_ p: Parser<Output, Failure>) -> Parser<Output, Failure> {
        p
    }
    public static func buildExpression<P: UsableInParserBuilder>(_ p: P) -> Parser<P.ParserBuilderOutput, P.ParserBuilderFailure> {
        p.parserForBuilder()
    }
    /// Structural types cannot conform to protocols
    public static func buildExpression<Output, Failure: Error>(_ p: @escaping PrimitiveParser<Output, Failure>) -> Parser<Output, Failure> {
        Parser(__primitiveParser: p)
    }
    /// Metatypes cannot conform to protocols
    public static func buildExpression<P: Parsable>(_ p: P.Type) -> Parser<P, P.ParseFailure> {
        Parsers.of(p)
    }
    /// We cannot extend Collection to conform to UsableInParserBuilder
    public static func buildExpression<PossiblePrefix: Collection>(_ p: PossiblePrefix) -> Parser<Substring, NoMatchFailure> where PossiblePrefix.Element == Character {
        Parsers.prefix(p)
    }
    
    public static func buildExpression<Output, Failure: Error>(_ p: Parser<Output, Failure>?) -> Parser<Output, Failure>? {
        p
    }
    public static func buildExpression<P: UsableInParserBuilder>(_ p: P?) -> Parser<P.ParserBuilderOutput, P.ParserBuilderFailure>? {
        p?.parserForBuilder()
    }
    public static func buildExpression<Output, Failure: Error>(_ p: PrimitiveParser<Output, Failure>?) -> Parser<Output, Failure>? {
        p.map(Parser.init(__primitiveParser:))
    }
    public static func buildExpression<P: Parsable>(_ p: P.Type?) -> Parser<P, P.ParseFailure>? {
        p.map(Parsers.of)
    }
    public static func buildExpression<PossiblePrefix: Collection>(_ p: PossiblePrefix?) -> Parser<Substring, NoMatchFailure>? where PossiblePrefix.Element == Character {
        p.map(Parsers.prefix)
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
    
    public static func buildOptional<Output, Failure: Error>(_ p: Parser<Output, Failure>?) -> Parser<Output, Failure>? {
        p
    }
    public static func buildBlock<O0, F0: Error, O1, F1: Error>(_ p0: Parser<O0, F0>?, _ p1: Parser<O1, F1>?) -> (Parser<O0, F0>?, Parser<O1, F1>?) {
        (p0, p1)
    }
    public static func buildBlock<O0, F0: Error, O1, F1: Error, O2, F2: Error>(_ p0: Parser<O0, F0>?, _ p1: Parser<O1, F1>?, _ p2: Parser<O2, F2>) -> (Parser<O0, F0>?, Parser<O1, F1>?, Parser<O2, F2>) {
        (p0, p1, p2)
    }
    
    public static func buildEither<Output, Failure: Error>(first p: Parser<Output, Failure>) -> Parser<Output, Failure> {
        p
    }
    public static func buildEither<Output, Failure: Error>(second p: Parser<Output, Failure>) -> Parser<Output, Failure> {
        p
    }
}
