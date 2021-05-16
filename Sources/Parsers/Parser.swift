public typealias PrimitiveParser<Stream: Collection, Output, Failure: Error> = (Stream, Stream.Index) -> Result<(Output, Stream.Index), Failure>

public protocol Parser {
    associatedtype Stream: Collection
    associatedtype Output
    associatedtype Failure: Error
    
    @ParserBuilder
    var parse: PrimitiveParser<Stream, Output, Failure> { get }
}

extension Parser {
    func parse(_ stream: Stream) -> Result<(Output, Stream.Index), Failure> {
        self.parse(stream, stream.startIndex)
    }
}

extension Parser where Failure == Never {
    func parse(_ stream: Stream) -> (Output, Stream.Index) {
        switch self.parse(stream, stream.startIndex) {
        // Cannot fail
        case .success(let (output, endIndex)):
            return (output, endIndex)
        }
    }
}

public enum Parsers {}
