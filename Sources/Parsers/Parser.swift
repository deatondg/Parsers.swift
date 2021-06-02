public typealias PrimitiveParser<Stream: Collection, Output, Failure: Error> = (Stream, Stream.Index) -> Result<(Output, Stream.Index), Failure>

public protocol Parser {
    associatedtype Stream: Collection
    associatedtype Output
    associatedtype Failure: Error
    
    @ParserBuilder
    var parse: PrimitiveParser<Stream, Output, Failure> { get }
}

public extension Parser {
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Failure> {
        self.parse(stream, index).map({ $0 })
    }
    func parse(from stream: Stream) -> Result<(value: Output, endIndex: Stream.Index), Failure> {
        self.parse(from: stream, startingAt: stream.startIndex)
    }
    func parse(from stream: Stream, startingAt index: Stream.Index) -> (value: Output, endIndex: Stream.Index) where Failure == Never {
        switch self.parse(stream, index) {
        // Cannot fail
        case .success(let (output, index)):
            return (output, index)
        }
    }
    func parse(from stream: Stream) -> (value: Output, endIndex: Stream.Index) where Failure == Never {
        self.parse(from: stream, startingAt: stream.startIndex)
    }
}

public enum Parsers {}
