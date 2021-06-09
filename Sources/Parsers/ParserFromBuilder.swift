public protocol ParserFromBuilder: ParserProtocol {
    @ParserBuilder
    var parser: Parser<Output, Failure> { get }
}
public extension ParserFromBuilder {
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        self.parser.parse(from: string, startingAt: index)
    }
}
