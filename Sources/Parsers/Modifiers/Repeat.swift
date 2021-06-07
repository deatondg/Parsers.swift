//@frozen
//public struct RepeatParserFailure<ParseOutput, ParseFailure: Error>: Error {
//    public let parsedOutputs: [ParseOutput]
//    public let parseFailure: ParseFailure
//    public let indexOfFailure: String.Index
//}
//
//struct RepeatParser<ParseOutput, ParseFailure: Error>: ParserProtocol {
//    typealias Output = [ParseOutput]
//    typealias Failure = RepeatParserFailure<ParseOutput, ParseFailure>
//    
//    let p: Parser<String, ParseOutput, ParseFailure>
//    
//    init(_ p: Parser<ParseOutput, ParseFailure>) {
//        self.p = p
//    }
//    
//    func parse(from string: String, startingAt index: String.Index) -> Result<(value: [ParseOutput], endIndex: String.Index), RepeatParserFailure<ParseOutput, ParseFailure>> {
//        var index = index
//        var outputs: [ParseOutput] = []
//        
//        while true {
//            switch p.parse(from: string, startingAt: index) {
//            case .failure(let failure):
//                return .failure(.init(parsedOutputs: outputs, parseFailure: failure, indexOfFailure: index))
//            case .success(let (output, newIndex)):
//                outputs.append(output)
//                /// If we have not progressed, we stop parsing
//                if newIndex == index {
//                    return .success((outputs, newIndex))
//                } else {
//                    index = newIndex
//                }
//            }
//        }
//    }
//}
//
//public extension ParserProtocol {
//    func `repeat`() -> Parser<[Output], RepeatParserFailure<Output, Failure>> {
//        RepeatParser(self).eraseToParser()
//    }
//}
