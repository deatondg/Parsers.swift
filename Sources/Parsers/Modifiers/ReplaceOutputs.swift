struct ReplaceOutputsParser<Stream: Collection, ParseOutput, Failure: Error, Output>: ParserProtocol {
    let p: Parser<Stream, ParseOutput, Failure>
    let o: Output
    
    init(_ p: Parser<Stream, ParseOutput, Failure>, _ o: Output) {
        self.p = p
        self.o = o
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Failure> {
        p.parse(from: stream, startingAt: index).map({ (_, index) in (o, index) })
    }
}

public extension Parser {
    func replaceOutputs<ReplaceOutput>(with o: ReplaceOutput) -> Parser<Stream, ReplaceOutput, Failure> {
        ReplaceOutputsParser(self, o).parser
    }
    func ignoreOutputs() -> Parser<Stream, (), Failure> {
        ReplaceOutputsParser(self, ()).parser
    }
}
