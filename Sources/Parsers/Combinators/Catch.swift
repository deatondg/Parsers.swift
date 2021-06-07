struct FCatchParser<Output, ParseFailure: Error, CatchFailure: Error>: ParserProtocol {
    typealias Failure = CatchFailure
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> Result<Output, CatchFailure>
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<Output, CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> Output) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<Output, ParseFailure>, _ k: KeyPath<ParseFailure, Result<Output, CatchFailure>>) {
        self.p = p
        self.c = { $0[keyPath: k] }
    }
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> CatchFailure) {
        self.p = p
        self.c = { .failure(c($0)) }
    }
    init(_ p: Parser<Output, ParseFailure>, _ k: KeyPath<ParseFailure, CatchFailure>) {
        self.p = p
        self.c = { .failure($0[keyPath: k]) }
    }
    init(_ p: Parser<Output, ParseFailure>, _ f: CatchFailure) {
        self.p = p
        self.c = { _ in .failure(f) }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), CatchFailure> {
        switch p.parse(from: string, startingAt: index) {
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

struct CatchParser<Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = Never
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> Output
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Output) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ k: KeyPath<ParseFailure, Output>) {
        self.p = p
        self.c = { $0[keyPath: k] }
    }
    init(_ p: Parser<Output, ParseFailure>, _ o: Output) {
        self.p = p
        self.c = { _ in o }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Never> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let parseFailure):
            return .success((c(parseFailure), index))
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

public extension ParserProtocol {
    func `catch`<CatchFailure>(_ c: @escaping (Failure) -> Result<Output, CatchFailure>) -> Parser<Output, CatchFailure> {
        FCatchParser(self.eraseToParser(), c).eraseToParser()
    }
    func `catch`(_ c: @escaping (Failure) throws -> Output) -> Parser<Output, Error> {
        FCatchParser(self.eraseToParser(), c).eraseToParser()
    }
    func `catch`<CatchFailure>(_ k: KeyPath<Failure, Result<Output, CatchFailure>>) -> Parser<Output, CatchFailure> {
        FCatchParser(self.eraseToParser(), k).eraseToParser()
    }
    
    func mapFailures<CatchFailure>(_ c: @escaping (Failure) -> CatchFailure) -> Parser<Output, CatchFailure> {
        FCatchParser(self.eraseToParser(), c).eraseToParser()
    }
    func mapFailures<CatchFailure>(_ c: KeyPath<Failure, CatchFailure>) -> Parser<Output, CatchFailure> {
        FCatchParser(self.eraseToParser(), c).eraseToParser()
    }
    
    func replaceFailures<CatchFailure>(withFailure f: CatchFailure) -> Parser<Output, CatchFailure> {
        FCatchParser(self.eraseToParser(), f).eraseToParser()
    }
    
    func `catch`(_ c: @escaping (Failure) -> Output) -> Parser<Output, Never> {
        CatchParser(self.eraseToParser(), c).eraseToParser()
    }
    func `catch`(_ k: KeyPath<Failure, Output>) -> Parser<Output, Never> {
        CatchParser(self.eraseToParser(), k).eraseToParser()
    }
    
    func replaceFailures(withOutput o: Output) -> Parser<Output, Never> {
        CatchParser(self.eraseToParser(), o).eraseToParser()
    }
    
    func assertNonfailing(file: String = #file, function: String = #function, line: Int = #line) -> Parser<Output, Never> {
        CatchParser(self.eraseToParser(), { fatalError("Parser.assertNonfailing() failed with \($0) in \(function) \(file):\(line).") }).eraseToParser()
    }
}
