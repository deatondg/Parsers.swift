@frozen
public enum MapParserFailure<ParseFailure: Error, MapFailure: Error>: Error {
    case parseFailure(ParseFailure)
    case mapFailure(MapFailure)
}

struct FMapFParser<ParseOutput, ParseFailure: Error, MapOutput, MapFailure: Error>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = MapParserFailure<ParseFailure, MapFailure>
    
    let p: Parser<ParseOutput, ParseFailure>
    let f: (ParseOutput) -> Result<MapOutput, MapFailure>
    
    init(_ p: Parser<ParseOutput, ParseFailure>, _ f: @escaping (ParseOutput) -> Result<MapOutput, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<ParseOutput, ParseFailure>, _ f: @escaping (ParseOutput) throws -> MapOutput) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<ParseOutput, ParseFailure>, _ k: KeyPath<ParseOutput, Result<MapOutput, MapFailure>>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapOutput, endIndex: String.Index), MapParserFailure<ParseFailure, MapFailure>> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let parseFailure):
            return .failure(.parseFailure(parseFailure))
        case .success(let (parseOutput, index)):
            switch f(parseOutput) {
            case .failure(let mapFailure):
                return .failure(.mapFailure(mapFailure))
            case .success(let mapOutput):
                return .success((mapOutput, index))
            }
        }
    }
}

struct FMapParser<ParseOutput, MapOutput, MapFailure: Error>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = MapFailure
    
    let p: Parser<ParseOutput, Never>
    let f: (ParseOutput) -> Result<MapOutput, MapFailure>
    
    init(_ p: Parser<ParseOutput, Never>, _ f: @escaping (ParseOutput) -> Result<MapOutput, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<ParseOutput, Never>, _ f: @escaping (ParseOutput) throws -> MapOutput) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<ParseOutput, Never>, _ k: KeyPath<ParseOutput, Result<MapOutput, MapFailure>>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapOutput, endIndex: String.Index), MapFailure> {
        let (parseOutput, index) = p.parse(from: string, startingAt: index)
        switch f(parseOutput) {
        case .success(let mapOutput):
            return .success((mapOutput, index))
        case .failure(let mapFailure):
            return .failure(mapFailure)
        }
    }
}

struct MapFParser<ParseOutput, ParseFailure: Error, MapOutput>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = ParseFailure
    
    let p: Parser<ParseOutput, ParseFailure>
    let f: (ParseOutput) -> MapOutput
    
    init(_ p: Parser<ParseOutput, ParseFailure>, _ f: @escaping (ParseOutput) -> MapOutput) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<ParseOutput, ParseFailure>, _ k: KeyPath<ParseOutput, MapOutput>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapOutput, endIndex: String.Index), ParseFailure> {
        switch p.parse(from: string, startingAt: index) {
        case .failure(let parseFailure):
            return .failure(parseFailure)
        case .success(let (parseOutput, index)):
            return .success((f(parseOutput), index))
        }
    }
}

struct MapParser<ParseOutput, MapOutput>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = Never
    
    let p: Parser<ParseOutput, Never>
    let f: (ParseOutput) -> MapOutput
    
    init(_ p: Parser<ParseOutput, Never>, _ f: @escaping (ParseOutput) -> MapOutput) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<ParseOutput, Never>, _ k: KeyPath<ParseOutput, MapOutput>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapOutput, endIndex: String.Index), Never> {
        let (parseOutput, index) = p.parse(from: string, startingAt: index)
        return .success((f(parseOutput), index))
    }
}

public extension Parser {
    func map<MapOutput, MapFailure>(_ f: @escaping (Output) -> Result<MapOutput, MapFailure>) -> Parser<MapOutput, MapParserFailure<Failure, MapFailure>> {
        FMapFParser(self, f).eraseToParser()
    }
    func map<MapOutput>(_ f: @escaping (Output) throws -> MapOutput) -> Parser<MapOutput, MapParserFailure<Failure, Error>> {
        FMapFParser(self, f).eraseToParser()
    }
    func map<MapOutput, MapFailure>(_ k: KeyPath<Output, Result<MapOutput, MapFailure>>) -> Parser<MapOutput, MapParserFailure<Failure, MapFailure>> {
        FMapFParser(self, k).eraseToParser()
    }
    
    func map<MapOutput, MapFailure>(_ f: @escaping (Output) -> Result<MapOutput, MapFailure>) -> Parser<MapOutput, MapFailure> where Failure == Never {
        FMapParser(self, f).eraseToParser()
    }
    func map<MapOutput>(_ f: @escaping (Output) throws -> MapOutput) -> Parser<MapOutput, Error> where Failure == Never {
        FMapParser(self, f).eraseToParser()
    }
    func map<MapOutput, MapFailure>(_ k: KeyPath<Output, Result<MapOutput, MapFailure>>) -> Parser<MapOutput, MapFailure> where Failure == Never {
        FMapParser(self, k).eraseToParser()
    }
    
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> Parser<MapOutput, Failure> {
        MapFParser(self, f).eraseToParser()
    }
    func map<MapOutput>(_ k: KeyPath<Output, MapOutput>) -> Parser<MapOutput, Failure> {
        MapFParser(self, k).eraseToParser()
    }
    
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> Parser<MapOutput, Never> where Failure == Never {
        MapParser(self, f).eraseToParser()
    }
    func map<MapOutput>(_ k: KeyPath<Output, MapOutput>) -> Parser<MapOutput, Never> where Failure == Never {
        MapParser(self, k).eraseToParser()
    }
}
