public struct CatchParser<P: Parser, CatchFailure: Error>: Parser {
    public typealias Stream = P.Stream
    public typealias Output = P.Output
    public typealias Failure = CatchFailure
    
    private let p: P
    private let c: (P.Failure) -> Result<P.Output, CatchFailure>
    
    public init(_ p: P, _ c: @escaping (P.Failure) -> Result<P.Output, CatchFailure>) {
        self.p = p
        self.c = c
    }
    public init(_ p: P, _ c: @escaping (P.Failure) throws -> P.Output) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    public init(_ p: P, _ c: @escaping (P.Failure) -> P.Output) where CatchFailure == Never {
        self.p = p
        self.c = { .success(c($0)) }
    }
    public init(_ p: P, _ c: P.Output) where CatchFailure == Never {
        self.p = p
        self.c = { _ in .success(c) }
    }
    
    public init(_ p: P, mapFailures f: @escaping (P.Failure) -> CatchFailure) {
        self.p = p
        self.c = { .failure(f($0)) }
    }
    public init(_ p: P, replaceFailuresWith f: CatchFailure) {
        self.p = p
        self.c = { _ in .failure(f) }
    }
    public init(assertNonfailing p: P, file: String = #file, function: String = #function, line: Int = #line) where CatchFailure == Never {
        self.p = p
        self.c = { fatalError("Parser.assertNonfailing() failed with \($0) in \(function) \(file):\(line).") }
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            switch p.parse(stream, index) {
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
}
extension Parser {
    func `catch`<CatchFailure: Error>(_ c: @escaping (Failure) -> Result<Output, CatchFailure>) -> CatchParser<Self, CatchFailure> {
        .init(self, c)
    }
    func `catch`(_ c: @escaping (Failure) throws -> Output) -> CatchParser<Self, Error> {
        .init(self, c)
    }
    func `catch`(_ c: @escaping (Failure) -> Output) -> CatchParser<Self, Never> {
        .init(self, c)
    }
    func `catch`(_ c: Output) -> CatchParser<Self, Never> {
        .init(self, c)
    }
}
extension Parser {
    func mapFailures<CatchFailure: Error>(_ f: @escaping (Failure) -> CatchFailure) -> CatchParser<Self, CatchFailure> {
        .init(self, mapFailures: f)
    }
    func replaceFailures<CatchFailure: Error>(with f: CatchFailure) -> CatchParser<Self, CatchFailure> {
        .init(self, replaceFailuresWith: f)
    }
    func assertNonfailing(file: String = #file, function: String = #function, line: Int = #line) -> CatchParser<Self, Never> {
        .init(assertNonfailing: self, file: file, function: function, line: line)
    }
}
