@frozen
public struct RepeatFailure<ParseOutput, ParseFailure: Error>: Error {
    public let parsedOutputs: [ParseOutput]
    public let parseFailure: ParseFailure
}

struct RepeatUntilEndParser<ParseOutput, ParseFailure: Error>: ParserProtocol {
    typealias Output = [ParseOutput]
    typealias Failure = RepeatFailure<ParseOutput, ParseFailure>
    
    let p: Parser<ParseOutput, ParseFailure>
    
    init(_ p: Parser<ParseOutput, ParseFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        var index = index
        var outputs: [ParseOutput] = []
        
        while true {
            switch p.parse(from: string, startingAt: index) {
            case .failure(let failure):
                return .failure(.init(parsedOutputs: outputs, parseFailure: failure))
            case .success(let (output, _index)):
                index = _index
                outputs.append(output)
                if index == string.endIndex {
                    return .success((outputs, index))
                }
            }
        }
    }
}

struct RepeatUntilStationaryParser<ParseOutput, ParseFailure: Error>: ParserProtocol {
    typealias Output = [ParseOutput]
    typealias Failure = RepeatFailure<ParseOutput, ParseFailure>
    
    let p: Parser<ParseOutput, ParseFailure>
    
    init(_ p: Parser<ParseOutput, ParseFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: [ParseOutput], endIndex: String.Index), RepeatFailure<ParseOutput, ParseFailure>> {
        var index = index
        var outputs: [ParseOutput] = []
        
        while true {
            switch p.parse(from: string, startingAt: index) {
            case .failure(let failure):
                return .failure(.init(parsedOutputs: outputs, parseFailure: failure))
            case .success(let (output, _index)):
                outputs.append(output)
                if _index == index {
                    return .success((outputs, index))
                } else {
                    index = _index
                }
            }
        }
    }
}

struct RepeatUntilFailureParser<ParseOutput, ParseFailure: Error>: ParserProtocol {
    typealias Output = (outputs: [ParseOutput], failure: ParseFailure)
    typealias Failure = Never
    
    let p: Parser<ParseOutput, ParseFailure>
    
    init(_ p: Parser<ParseOutput, ParseFailure>) {
        self.p = p
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: (outputs: [ParseOutput], failure: ParseFailure), endIndex: String.Index), Never> {
        var index = index
        var outputs: [ParseOutput] = []
        
        while true {
            switch p.parse(from: string, startingAt: index) {
            case .failure(let failure):
                return .success(((outputs, failure), index))
            case .success(let (output, _index)):
                index = _index
                outputs.append(output)
            }
        }
    }
}

public extension ParserProtocol {
    // repeatUntilEnd() will hang if a parser continues to succeed but consumes no input.
    func repeatUntilEnd() -> Parser<[Output], RepeatFailure<Output, Failure>> {
        RepeatUntilEndParser(self.eraseToParser()).eraseToParser()
    }
    func repeatUntilStationary() -> Parser<[Output], RepeatFailure<Output, Failure>> {
        RepeatUntilStationaryParser(self.eraseToParser()).eraseToParser()
    }
    // repeatUntilFailure() will hang if a parser does not eventually fail.
    func repeatUntilFailure() -> Parser<(outputs: [Output], failure: Failure), Never> {
        RepeatUntilFailureParser(self.eraseToParser()).eraseToParser()
    }
}
