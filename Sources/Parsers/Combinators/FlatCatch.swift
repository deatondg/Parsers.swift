@frozen
public enum FlatCatchParserFailure<CatchFailure: Error, ParseFailure: Error>: Error {
    case catchFailure(CatchFailure)
    case parseFailure(ParseFailure)
}

struct FFlatFCatchParser<Output, ParseFailure: Error, CatchParser: ParserProtocol, CatchFailure: Error>: ParserProtocol where CatchParser.Output == Output {
    typealias Failure = FlatCatchParserFailure<CatchFailure, CatchParser.Failure>
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> Result<CatchParser, CatchFailure>
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<CatchParser, CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> CatchParser) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), FlatCatchParserFailure<CatchFailure, CatchParser.Failure>> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let outerFailure):
            switch c(outerFailure) {
            case .failure(let catchFailure):
                return .failure(.catchFailure(catchFailure))
            case .success(let catchParser):
                switch catchParser.parse(from: string, startingAt: index) {
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

struct FlatFCatchParser<Output, ParseFailure: Error, CatchParser: ParserProtocol, CatchFailure: Error>: ParserProtocol where CatchParser.Output == Output, CatchParser.Failure == Never {
    typealias Failure = CatchFailure
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> Result<CatchParser, CatchFailure>
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<CatchParser, CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> CatchParser) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), CatchFailure> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let outerFailure):
            switch c(outerFailure) {
            case .failure(let catchFailure):
                return .failure(catchFailure)
            case .success(let catchParser):
                return .success(catchParser.parse(from: string, startingAt: index))
            }
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

struct FFlatCatchParser<Output, ParseFailure: Error, CatchParser: ParserProtocol>: ParserProtocol where CatchParser.Output == Output {
    typealias Failure = CatchParser.Failure
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> CatchParser
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> CatchParser) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ c: CatchParser) {
        self.p = p
        self.c = { _ in c }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), CatchParser.Failure> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let outerFailure):
            switch c(outerFailure).parse(from: string, startingAt: index) {
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

struct FlatCatchParser<Output, ParseFailure: Error, CatchParser: ParserProtocol>: ParserProtocol where CatchParser.Output == Output, CatchParser.Failure == Never {
    typealias Failure = Never
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> CatchParser
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> CatchParser) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ c: CatchParser) {
        self.p = p
        self.c = { _ in c }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Never> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let outerFailure):
            return .success(c(outerFailure).parse(from: string, startingAt: index))
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

public extension Parser {
    func `catch`<CatchParser: ParserProtocol, CatchFailure: Error>(_ c: @escaping (Failure) -> Result<CatchParser, CatchFailure>) -> Parser<Output, FlatCatchParserFailure<CatchFailure, CatchParser.Failure>> where CatchParser.Output == Output {
        FFlatFCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) throws -> CatchParser) -> Parser<Output, FlatCatchParserFailure<Error, CatchParser.Failure>> where CatchParser.Output == Output {
        FFlatFCatchParser(self, c).parser
    }
    
    func `catch`<CatchParser: ParserProtocol, CatchFailure: Error>(_ c: @escaping (Failure) -> Result<CatchParser, CatchFailure>) -> Parser<Output, CatchFailure> where CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatFCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) throws -> CatchParser) -> Parser<Output, Error> where CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatFCatchParser(self, c).parser
    }
    
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) -> CatchParser) -> Parser<Output, CatchParser.Failure> where CatchParser.Output == Output {
        FFlatCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: CatchParser) -> Parser<Output, CatchParser.Failure> where CatchParser.Output == Output {
        FFlatCatchParser(self, c).parser
    }
    
    func `catch`<CatchParser: ParserProtocol>(_ c: @escaping (Failure) -> CatchParser) -> Parser<Output, Never> where CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatCatchParser(self, c).parser
    }
    func `catch`<CatchParser: ParserProtocol>(_ c: CatchParser) -> Parser<Output, Never> where CatchParser.Output == Output, CatchParser.Failure == Never {
        FlatCatchParser(self, c).parser
    }
}
