@frozen
public enum FlattenParserFailure<OuterFailure: Error, InnerFailure: Error>: Error {
    case outerFailure(OuterFailure)
    case innerFailure(InnerFailure)
}

struct FFlattenFParser<OuterOutput, OuterFailure: Error>: ParserProtocol where OuterOutput: ParserProtocol {
    typealias Output = OuterOutput.Output
    typealias Failure = FlattenParserFailure<OuterFailure, OuterOutput.Failure>
    
    let p: Parser< OuterOutput, OuterFailure>
    
    init(_ p: Parser<OuterOutput, OuterFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OuterOutput.Output, endIndex: String.Index), FlattenParserFailure<OuterFailure, OuterOutput.Failure>> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let outerFailure):
            return .failure(.outerFailure(outerFailure))
        case .success(let (outerOutput, index)):
            switch outerOutput.parse(from: string, startingAt: index) {
            case .failure(let innerFailure):
                return .failure(.innerFailure(innerFailure))
            case .success(let (innerOutput, index)):
                return .success((innerOutput, index))
            }
        }
    }
}

struct FlattenFParser<OuterOutput, OuterFailure: Error>: ParserProtocol where OuterOutput: ParserProtocol, OuterOutput.Failure == Never {
    typealias Output = OuterOutput.Output
    typealias Failure = OuterFailure
    
    let p: Parser<OuterOutput, OuterFailure>
    
    init(_ p: Parser<OuterOutput, OuterFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OuterOutput.Output, endIndex: String.Index), OuterFailure> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let outerFailure):
            return .failure(outerFailure)
        case .success(let (outerOutput, index)):
            return .success(outerOutput.parse(from: string, startingAt: index))
        }
    }
}

struct FFlattenParser<OuterOutput>: ParserProtocol where OuterOutput: ParserProtocol {
    typealias Output = OuterOutput.Output
    typealias Failure = OuterOutput.Failure
    
    let p: Parser<OuterOutput, Never>
    
    init(_ p: Parser<OuterOutput, Never>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OuterOutput.Output, endIndex: String.Index), OuterOutput.Failure> {
        let (outerOutput, index) = p.parse(from: string, startingAt: index)
        switch outerOutput.parse(from: string, startingAt: index) {
        case .failure(let innerFailure):
            return .failure(innerFailure)
        case .success(let (innerOutput, index)):
            return .success((innerOutput, index))
        }
    }
}

struct FlattenParser<OuterOutput>: ParserProtocol where OuterOutput: ParserProtocol, OuterOutput.Failure == Never {
    typealias Output = OuterOutput.Output
    typealias Failure = Never
    
    let p: Parser<OuterOutput, Never>
    
    init(_ p: Parser<OuterOutput, Never>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OuterOutput.Output, endIndex: String.Index), Never> {
        let (outerOutput, index) = p.parse(from: string, startingAt: index)
        return .success(outerOutput.parse(from: string, startingAt: index))
    }
}

public extension ParserProtocol {
    func flatten() -> Parser<Output.Output, FlattenParserFailure<Failure, Output.Failure>> where Output: ParserProtocol {
        FFlattenFParser(self.eraseToParser()).eraseToParser()
    }
    func flatten() -> Parser<Output.Output, Failure> where Output: ParserProtocol, Output.Failure == Never {
        FlattenFParser(self.eraseToParser()).eraseToParser()
    }
    func flatten() -> Parser<Output.Output, Output.Failure> where Output: ParserProtocol, Failure == Never {
        FFlattenParser(self.eraseToParser()).eraseToParser()
    }
    func flatten() -> Parser<Output.Output, Never> where Output: ParserProtocol, Output.Failure == Never, Failure == Never {
        FlattenParser(self.eraseToParser()).eraseToParser()
    }
}
