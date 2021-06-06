@frozen
public struct RepeatParserFailure<Stream: Collection, ParseOutput, ParseFailure: Error>: Error {
    public let parsedOutputs: [ParseOutput]
    public let parseFailure: ParseFailure
    public let indexOfFailure: Stream.Index
}

struct RepeatParser<Stream: Collection, ParseOutput, ParseFailure: Error>: ParserProtocol {
    typealias Output = [ParseOutput]
    typealias Failure = RepeatParserFailure<Stream, ParseOutput, ParseFailure>
    
    let p: Parser<Stream, ParseOutput, ParseFailure>
    
    init(_ p: Parser<Stream, ParseOutput, ParseFailure>) {
        self.p = p
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: [ParseOutput], endIndex: Stream.Index), RepeatParserFailure<Stream, ParseOutput, ParseFailure>> {
        var index = index
        var outputs: [ParseOutput] = []
        
        while true {
            switch p.parse(from: stream, startingAt: index) {
            case .failure(let failure):
                return .failure(.init(parsedOutputs: outputs, parseFailure: failure, indexOfFailure: index))
            case .success(let (output, newIndex)):
                outputs.append(output)
                /// If we have not progressed, we stop parsing
                if newIndex == index {
                    return .success((outputs, newIndex))
                } else {
                    index = newIndex
                }
            }
        }
    }
}

public extension Parser {
    func `repeat`() -> Parser<Stream, [Output], RepeatParserFailure<Stream, Output, Failure>> {
        RepeatParser(self).parser
    }
}
