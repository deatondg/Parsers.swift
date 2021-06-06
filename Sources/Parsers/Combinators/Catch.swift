struct FCatchParser<Stream: Collection, Output, ParseFailure: Error, CatchFailure: Error>: ParserProtocol {
    typealias Failure = CatchFailure
    
    let p: Parser<Stream, Output, ParseFailure>
    let c: (ParseFailure) -> Result<Output, CatchFailure>
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<Output, CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> Output) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ k: KeyPath<ParseFailure, Result<Output, CatchFailure>>) {
        self.p = p
        self.c = { $0[keyPath: k] }
    }
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> CatchFailure) {
        self.p = p
        self.c = { .failure(c($0)) }
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ k: KeyPath<ParseFailure, CatchFailure>) {
        self.p = p
        self.c = { .failure($0[keyPath: k]) }
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ f: CatchFailure) {
        self.p = p
        self.c = { _ in .failure(f) }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), CatchFailure> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let parseFailure):
            switch c(parseFailure) {
            case .failure(let catchFailure):
                return .failure(catchFailure)
            case .success(let output):
                return .success((output, index))
            }
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

struct CatchParser<Stream: Collection, Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = Never
    
    let p: Parser<Stream, Output, ParseFailure>
    let c: (ParseFailure) -> Output
    
    init(_ p: Parser<Stream, Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Output) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ k: KeyPath<ParseFailure, Output>) {
        self.p = p
        self.c = { $0[keyPath: k] }
    }
    init(_ p: Parser<Stream, Output, ParseFailure>, _ o: Output) {
        self.p = p
        self.c = { _ in o }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: Output, endIndex: Stream.Index), Never> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let parseFailure):
            return .success((c(parseFailure), index))
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

public extension Parser {
    func `catch`<CatchFailure>(_ c: @escaping (Failure) -> Result<Output, CatchFailure>) -> Parser<Stream, Output, CatchFailure> {
        FCatchParser(self, c).parser
    }
    func `catch`(_ c: @escaping (Failure) throws -> Output) -> Parser<Stream, Output, Error> {
        FCatchParser(self, c).parser
    }
    func `catch`<CatchFailure>(_ k: KeyPath<Failure, Result<Output, CatchFailure>>) -> Parser<Stream, Output, CatchFailure> {
        FCatchParser(self, k).parser
    }
    
    func mapFailures<CatchFailure>(_ c: @escaping (Failure) -> CatchFailure) -> Parser<Stream, Output, CatchFailure> {
        FCatchParser(self, c).parser
    }
    func mapFailures<CatchFailure>(_ c: KeyPath<Failure, CatchFailure>) -> Parser<Stream, Output, CatchFailure> {
        FCatchParser(self, c).parser
    }
    
    func replaceFailures<CatchFailure>(withFailure f: CatchFailure) -> Parser<Stream, Output, CatchFailure> {
        FCatchParser(self, f).parser
    }
    
    func `catch`(_ c: @escaping (Failure) -> Output) -> Parser<Stream, Output, Never> {
        CatchParser(self, c).parser
    }
    func `catch`(_ k: KeyPath<Failure, Output>) -> Parser<Stream, Output, Never> {
        CatchParser(self, k).parser
    }
    
    func replaceFailures(withOutput o: Output) -> Parser<Stream, Output, Never> {
        CatchParser(self, o).parser
    }
    
    func assertNonfailing(file: String = #file, function: String = #function, line: Int = #line) -> Parser<Stream, Output, Never> {
        CatchParser(self, { fatalError("Parser.assertNonfailing() failed with \($0) in \(function) \(file):\(line).") }).parser
    }
}
