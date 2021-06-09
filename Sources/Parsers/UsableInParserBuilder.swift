public protocol UsableInParserBuilder {
    associatedtype ParserBuilderOutput
    associatedtype ParserBuilderFailure: Error
    
    func parserForBuilder() -> Parser<ParserBuilderOutput, ParserBuilderFailure>
}
