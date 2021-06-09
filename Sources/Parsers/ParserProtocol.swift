public protocol ParserProtocol: UsableInParserBuilder where ParserBuilderOutput == Output, ParserBuilderFailure == Failure {
    associatedtype Output
    associatedtype Failure//: Error /// Annoyingly, leaving this here gives a warning. I think it's a poorly-considered warning.
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure>
    
    /// This is inside the protocol instead of just in an extension so that the default implementation can be overridden.
    func eraseToParser() -> Parser<Output, Failure>
}

public extension ParserProtocol {
    // TODO: Use the correct API
    func eraseToParser() -> Parser<Output, Failure> {
        Parser(__primitiveParser: self.parse)
    }
    func parserForBuilder() -> Parser<Output, Failure> { self.eraseToParser() }
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
