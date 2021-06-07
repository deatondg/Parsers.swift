struct ReplaceOutputsParser<ParseOutput, Failure: Error, Output>: ParserProtocol {
    let p: Parser<ParseOutput, Failure>
    let o: Output
    
    init(_ p: Parser<ParseOutput, Failure>, _ o: Output) {
        self.p = p
        self.o = o
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Failure> {
        p.parse(from: string, startingAt: index).map({ (_, index) in (o, index) })
    }
}

public extension Parser {
    func replaceOutputs<ReplaceOutput>(with o: ReplaceOutput) -> Parser<ReplaceOutput, Failure> {
        ReplaceOutputsParser(self, o).parser
    }
    func ignoreOutputs() -> Parser<(), Failure> {
        ReplaceOutputsParser(self, ()).parser
    }
}
