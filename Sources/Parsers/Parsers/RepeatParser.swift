public struct RepeatParser<P: Parser>: Parser {
    public typealias Stream = P.Stream
    public typealias Output = [P.Output]
    public struct Failure: Error {
        public let parsedOutputs: [P.Output]
        public let parseFailure: P.Failure
        public let indexOfFailure: Stream.Index
    }
    
    private let p: P
    
    public init(_ p: P) {
        self.p = p
    }
    
    public var parse: PrimitiveParser<P.Stream, [P.Output], Failure> {
        return { stream, index in
            let parse = p.parse
            var index = index
            var outputs: [P.Output] = []
            
            while true {
                switch parse(stream, index) {
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
}
