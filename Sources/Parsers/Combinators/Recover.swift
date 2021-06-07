struct FRecoverParser<Output, ParseFailure: Error, CatchFailure: Error>: ParserProtocol {
    typealias Failure = CatchFailure
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> Result<(value: Output, endIndex: String.Index), CatchFailure>
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> Result<(value: Output, endIndex: String.Index), CatchFailure>) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) throws -> (value: Output, endIndex: String.Index)) where CatchFailure == Error {
        self.p = p
        self.c = {
            do {
                return .success(try c($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<Output, ParseFailure>, _ k: KeyPath<ParseFailure, Result<(value: Output, endIndex: String.Index), CatchFailure>>) {
        self.p = p
        self.c = { $0[keyPath: k] }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), CatchFailure> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let parseFailure):
            switch c(parseFailure) {
            case .failure(let catchFailure):
                return .failure(catchFailure)
            case .success(let (catchOutput, index)):
                return .success((catchOutput, index))
            }
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

struct RecoverParser<Output, ParseFailure: Error>: ParserProtocol {
    typealias Failure = Never
    
    let p: Parser<Output, ParseFailure>
    let c: (ParseFailure) -> (value: Output, endIndex: String.Index)
    
    init(_ p: Parser<Output, ParseFailure>, _ c: @escaping (ParseFailure) -> (value: Output, endIndex: String.Index)) {
        self.p = p
        self.c = c
    }
    init(_ p: Parser<Output, ParseFailure>, _ k: KeyPath<ParseFailure, (value: Output, endIndex: String.Index)>) {
        self.p = p
        self.c = { $0[keyPath: k] }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: Output, endIndex: String.Index), Never> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let parseFailure):
            return .success(c(parseFailure))
        case .success(let (output, index)):
            return .success((output, index))
        }
    }
}

public extension Parser {
    func recover<CatchFailure>(_ c: @escaping (Failure) -> Result<(value: Output, endIndex: String.Index), CatchFailure>) -> Parser<Output, CatchFailure> {
        FRecoverParser(self, c).parser
    }
    func recover(_ c: @escaping (Failure) throws -> (value: Output, endIndex: String.Index)) -> Parser<Output, Error> {
        FRecoverParser(self, c).parser
    }
    func recover<CatchFailure>(_ k: KeyPath<Failure, Result<(value: Output, endIndex: String.Index), CatchFailure>>) -> Parser<Output, CatchFailure> {
        FRecoverParser(self, k).parser
    }
    
    func recover(_ c: @escaping (Failure) -> (value: Output, endIndex: String.Index)) -> Parser<Output, Never> {
        RecoverParser(self, c).parser
    }
    func recover(_ k: KeyPath<Failure, (value: Output, endIndex: String.Index)>) -> Parser<Output, Never> {
        RecoverParser(self, k).parser
    }
}
