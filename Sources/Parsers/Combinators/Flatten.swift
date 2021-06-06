@frozen
public enum FlattenParserFailure<OuterFailure: Error, InnerFailure: Error>: Error {
    case outerFailure(OuterFailure)
    case innerFailure(InnerFailure)
}

struct FFlattenFParser<Stream, OuterOutput, OuterFailure: Error>: ParserProtocol where OuterOutput: ParserProtocol, OuterOutput.Stream == Stream {
    typealias Output = OuterOutput.Output
    typealias Failure = FlattenParserFailure<OuterFailure, OuterOutput.Failure>
    
    let p: Parser<Stream, OuterOutput, OuterFailure>
    
    init(_ p: Parser<Stream, OuterOutput, OuterFailure>) {
        self.p = p
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: OuterOutput.Output, endIndex: Stream.Index), FlattenParserFailure<OuterFailure, OuterOutput.Failure>> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let outerFailure):
            return .failure(.outerFailure(outerFailure))
        case .success(let (outerOutput, index)):
            switch outerOutput.parse(from: stream, startingAt: index) {
            case .failure(let innerFailure):
                return .failure(.innerFailure(innerFailure))
            case .success(let (innerOutput, index)):
                return .success((innerOutput, index))
            }
        }
    }
}

struct FlattenFParser<Stream, OuterOutput, OuterFailure: Error>: ParserProtocol where OuterOutput: ParserProtocol, OuterOutput.Stream == Stream, OuterOutput.Failure == Never {
    typealias Output = OuterOutput.Output
    typealias Failure = OuterFailure
    
    let p: Parser<Stream, OuterOutput, OuterFailure>
    
    init(_ p: Parser<Stream, OuterOutput, OuterFailure>) {
        self.p = p
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: OuterOutput.Output, endIndex: Stream.Index), OuterFailure> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let outerFailure):
            return .failure(outerFailure)
        case .success(let (outerOutput, index)):
            return .success(outerOutput.parse(from: stream, startingAt: index))
        }
    }
}

struct FFlattenParser<Stream, OuterOutput>: ParserProtocol where OuterOutput: ParserProtocol, OuterOutput.Stream == Stream {
    typealias Output = OuterOutput.Output
    typealias Failure = OuterOutput.Failure
    
    let p: Parser<Stream, OuterOutput, Never>
    
    init(_ p: Parser<Stream, OuterOutput, Never>) {
        self.p = p
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: OuterOutput.Output, endIndex: Stream.Index), OuterOutput.Failure> {
        let (outerOutput, index) = p.parse(from: stream, startingAt: index)
        switch outerOutput.parse(from: stream, startingAt: index) {
        case .failure(let innerFailure):
            return .failure(innerFailure)
        case .success(let (innerOutput, index)):
            return .success((innerOutput, index))
        }
    }
}

struct FlattenParser<Stream, OuterOutput>: ParserProtocol where OuterOutput: ParserProtocol, OuterOutput.Stream == Stream, OuterOutput.Failure == Never {
    typealias Output = OuterOutput.Output
    typealias Failure = Never
    
    let p: Parser<Stream, OuterOutput, Never>
    
    init(_ p: Parser<Stream, OuterOutput, Never>) {
        self.p = p
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: OuterOutput.Output, endIndex: Stream.Index), Never> {
        let (outerOutput, index) = p.parse(from: stream, startingAt: index)
        return .success(outerOutput.parse(from: stream, startingAt: index))
    }
}

public extension Parser {
    func flatten() -> Parser<Stream, Output.Output, FlattenParserFailure<Failure, Output.Failure>> where Output: ParserProtocol, Output.Stream == Stream {
        FFlattenFParser(self).parser
    }
    func flatten() -> Parser<Stream, Output.Output, Failure> where Output: ParserProtocol, Output.Stream == Stream, Output.Failure == Never {
        FlattenFParser(self).parser
    }
    func flatten() -> Parser<Stream, Output.Output, Output.Failure> where Output: ParserProtocol, Output.Stream == Stream, Failure == Never {
        FFlattenParser(self).parser
    }
    func flatten() -> Parser<Stream, Output.Output, Never> where Output: ParserProtocol, Output.Stream == Stream, Output.Failure == Never, Failure == Never {
        FlattenParser(self).parser
    }
}
