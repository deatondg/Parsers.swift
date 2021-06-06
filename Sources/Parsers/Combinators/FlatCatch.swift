@frozen
public enum FlatCatchParserFailure<CatchFailure: Error, ParseFailure: Error>: Error {
    case catchFailure(CatchFailure)
    case parseFailure(ParseFailure)
}

struct FFlatFCatchParser<Stream, Output, ParseFailure: Error, CatchParser: ParserProtocol, CatchFailure: Error>: ParserProtocol where CatchParser.Stream == Stream, CatchParser.Output == Output {
    typealias Failure = FlatCatchParserFailure<CatchFailure, CatchParser.Failure>
    
    let p: Parser<Stream, Output, ParseFailure>
    let c: (ParseFailure) -> Result<CatchParser, CatchFailure>
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<CatchParser, CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> CatchParser) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), FlatCatchParserFailure<CatchFailure, CatchParser.Failure>> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let outerFailure):
            switch c(outerFailure) {
            case .failure(let catchFailure):
                return .failure(.catchFailure(catchFailure))
            case .success(let catchParser):
                switch catchParser.parse(from: stream, startingAt: index) {
                case .failure(let parseFailure):
                    return .failure(.parseFailure(parseFailure))
                case .success(let (catchOutput, index)):
                    return .success((catchOutput, index))
                }
            }
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

struct FlatFCatchParser<Stream, Output, ParseFailure: Error, CatchParser: ParserProtocol, CatchFailure: Error>: ParserProtocol where CatchParser.Stream == Stream, CatchParser.Output == Output, CatchParser.Failure == Never {
    typealias Failure = CatchFailure
    
    let p: Parser<Stream, Output, ParseFailure>
    let c: (ParseFailure) -> Result<CatchParser, CatchFailure>
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<CatchParser, CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> CatchParser) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), CatchFailure> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let outerFailure):
            switch c(outerFailure) {
            case .failure(let catchFailure):
                return .failure(catchFailure)
            case .success(let catchParser):
                return .success(catchParser.parse(from: stream, startingAt: index))
            }
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

struct FFlatCatchParser<Stream, Output, ParseFailure: Error, CatchParser: ParserProtocol>: ParserProtocol where CatchParser.Stream == Stream, CatchParser.Output == Output {
    typealias Failure = CatchParser.Failure
    
    let p: Parser<Stream, Output, ParseFailure>
    let c: (ParseFailure) -> CatchParser
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> CatchParser) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: CatchParser) {
        self.p = p
        self.c = { _ in c }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), CatchParser.Failure> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let outerFailure):
            switch c(outerFailure).parse(from: stream, startingAt: index) {
            case .failure(let parseFailure):
                return .failure(parseFailure)
            case .success(let (catchOutput, index)):
                return .success((catchOutput, index))
            }
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

struct FlatCatchParser<Stream, Output, ParseFailure: Error, CatchParser: ParserProtocol>: ParserProtocol where CatchParser.Stream == Stream, CatchParser.Output == Output, CatchParser.Failure == Never {
    typealias Failure = Never
    
    let p: Parser<Stream, Output, ParseFailure>
    let c: (ParseFailure) -> CatchParser
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> CatchParser) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: CatchParser) {
        self.p = p
        self.c = { _ in c }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Never> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let outerFailure):
            return .success(c(outerFailure).parse(from: stream, startingAt: index))
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

public extension Parser {
    func `catch`<CatchParser: ParserProtocol, CatchFailure: Error>(_ c: @escaping (Failure) -> Result<CatchParser, CatchFailure>) -> Parser<Stream, Output, FlatCatchParserFailure<CatchFailure, CatchParser.Failure>> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        FFlatFCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) throws -> CatchParser) -> Parser<Stream, Output, FlatCatchParserFailure<Error, CatchParser.Failure>> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        FFlatFCatchParser(self, c).parser
    }
    
    func `catch`<CatchParser: ParserProtocol, CatchFailure: Error>(_ c: @escaping (Failure) -> Result<CatchParser, CatchFailure>) -> Parser<Stream, Output, CatchFailure> where CatchParser.Stream == Stream, CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatFCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) throws -> CatchParser) -> Parser<Stream, Output, Error> where CatchParser.Stream == Stream, CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatFCatchParser(self, c).parser
    }
    
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) -> CatchParser) -> Parser<Stream, Output, CatchParser.Failure> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        FFlatCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: CatchParser) -> Parser<Stream, Output, CatchParser.Failure> where CatchParser.Stream == Stream, CatchParser.Output == Output {
        FFlatCatchParser(self, c).parser
    }
    
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) -> CatchParser) -> Parser<Stream, Output, Never> where CatchParser.Stream == Stream, CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: CatchParser) -> Parser<Stream, Output, Never> where CatchParser.Stream == Stream, CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatCatchParser(self, c).parser
    }
}
