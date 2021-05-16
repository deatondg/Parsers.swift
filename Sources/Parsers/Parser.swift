public typealias PrimitiveParser<Stream: Collection, Output, Failure: Error> = (Stream.SubSequence) -> Result<(Output, Stream.SubSequence), Failure>

public protocol Parser {
    associatedtype Stream: Collection
    associatedtype Output
    associatedtype Failure: Error
    
    @ParserBuilder
    var parse: PrimitiveParser<Stream, Output, Failure> { get }
}

extension Parser {
    func parse(_ stream: Stream) -> Result<(Output, Stream.SubSequence), Failure> {
        self.parse(stream[...])
    }
}

extension Parser where Failure == Never {
    func parse(_ stream: Stream.SubSequence) -> (Output, Stream.SubSequence) {
        switch self.parse(stream) {
        // Cannot fail
        case .success(let (output, stream)):
            return (output, stream)
        }
    }
    func parse(_ stream: Stream) -> (Output, Stream.SubSequence) {
        switch self.parse(stream[...]) {
        // Cannot fail
        case .success(let (output, stream)):
            return (output, stream)
        }
    }
}

public enum Parsers {}
