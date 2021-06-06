@frozen
public enum MapParserFailure<ParseFailure: Error, MapFailure: Error>: Error {
    case parseFailure(ParseFailure)
    case mapFailure(MapFailure)
}

struct FMapFParser<Stream: Collection, ParseOutput, ParseFailure: Error, MapOutput, MapFailure: Error>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = MapParserFailure<ParseFailure, MapFailure>
    
    let p: Parser<Stream, ParseOutput, ParseFailure>
    let f: (ParseOutput) -> Result<MapOutput, MapFailure>
    
    init(_ p: Parser<Stream, ParseOutput, ParseFailure>, _ f: @escaping (ParseOutput) -> Result<MapOutput, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<Stream, ParseOutput, ParseFailure>, _ f: @escaping (ParseOutput) throws -> MapOutput) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<Stream, ParseOutput, ParseFailure>, _ k: KeyPath<ParseOutput, Result<MapOutput, MapFailure>>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapOutput, endIndex: Stream.Index), MapParserFailure<ParseFailure, MapFailure>> {
        switch p.parse(from: stream, startingAt: index) {
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

struct FMapParser<Stream: Collection, ParseOutput, MapOutput, MapFailure: Error>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = MapFailure
    
    let p: Parser<Stream, ParseOutput, Never>
    let f: (ParseOutput) -> Result<MapOutput, MapFailure>
    
    init(_ p: Parser<Stream, ParseOutput, Never>, _ f: @escaping (ParseOutput) -> Result<MapOutput, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<Stream, ParseOutput, Never>, _ f: @escaping (ParseOutput) throws -> MapOutput) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    init(_ p: Parser<Stream, ParseOutput, Never>, _ k: KeyPath<ParseOutput, Result<MapOutput, MapFailure>>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapOutput, endIndex: Stream.Index), MapFailure> {
        let (parseOutput, index) = p.parse(from: stream, startingAt: index)
        switch f(parseOutput) {
        case .success(let mapOutput):
            return .success((mapOutput, index))
        case .failure(let mapFailure):
            return .failure(mapFailure)
        }
    }
}

struct MapFParser<Stream: Collection, ParseOutput, ParseFailure: Error, MapOutput>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = ParseFailure
    
    let p: Parser<Stream, ParseOutput, ParseFailure>
    let f: (ParseOutput) -> MapOutput
    
    init(_ p: Parser<Stream, ParseOutput, ParseFailure>, _ f: @escaping (ParseOutput) -> MapOutput) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<Stream, ParseOutput, ParseFailure>, _ k: KeyPath<ParseOutput, MapOutput>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapOutput, endIndex: Stream.Index), ParseFailure> {
        switch p.parse(from: stream, startingAt: index) {
        case .failure(let parseFailure):
            return .failure(parseFailure)
        case .success(let (parseOutput, index)):
            return .success((f(parseOutput), index))
        }
    }
}

struct MapParser<Stream: Collection, ParseOutput, MapOutput>: ParserProtocol {
    typealias Output = MapOutput
    typealias Failure = Never
    
    let p: Parser<Stream, ParseOutput, Never>
    let f: (ParseOutput) -> MapOutput
    
    init(_ p: Parser<Stream, ParseOutput, Never>, _ f: @escaping (ParseOutput) -> MapOutput) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<Stream, ParseOutput, Never>, _ k: KeyPath<ParseOutput, MapOutput>) {
        self.p = p
        self.f = { $0[keyPath: k] }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapOutput, endIndex: Stream.Index), Never> {
        let (parseOutput, index) = p.parse(from: stream, startingAt: index)
        return .success((f(parseOutput), index))
    }
}

public extension Parser {
    func map<MapOutput, MapFailure>(_ f: @escaping (Output) -> Result<MapOutput, MapFailure>) -> Parser<Stream, MapOutput, MapParserFailure<Failure, MapFailure>> {
        FMapFParser(self, f).parser
    }
    func map<MapOutput>(_ f: @escaping (Output) throws -> MapOutput) -> Parser<Stream, MapOutput, MapParserFailure<Failure, Error>> {
        FMapFParser(self, f).parser
    }
    func map<MapOutput, MapFailure>(_ k: KeyPath<Output, Result<MapOutput, MapFailure>>) -> Parser<Stream, MapOutput, MapParserFailure<Failure, MapFailure>> {
        FMapFParser(self, k).parser
    }
    
    func map<MapOutput, MapFailure>(_ f: @escaping (Output) -> Result<MapOutput, MapFailure>) -> Parser<Stream, MapOutput, MapFailure> where Failure == Never {
        FMapParser(self, f).parser
    }
    func map<MapOutput>(_ f: @escaping (Output) throws -> MapOutput) -> Parser<Stream, MapOutput, Error> where Failure == Never {
        FMapParser(self, f).parser
    }
    func map<MapOutput, MapFailure>(_ k: KeyPath<Output, Result<MapOutput, MapFailure>>) -> Parser<Stream, MapOutput, MapFailure> where Failure == Never {
        FMapParser(self, k).parser
    }
    
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> Parser<Stream, MapOutput, Failure> {
        MapFParser(self, f).parser
    }
    func map<MapOutput>(_ k: KeyPath<Output, MapOutput>) -> Parser<Stream, MapOutput, Failure> {
        MapFParser(self, k).parser
    }
    
    func map<MapOutput>(_ f: @escaping (Output) -> MapOutput) -> Parser<Stream, MapOutput, Never> where Failure == Never {
        MapParser(self, f).parser
    }
    func map<MapOutput>(_ k: KeyPath<Output, MapOutput>) -> Parser<Stream, MapOutput, Never> where Failure == Never {
        MapParser(self, k).parser
    }
}
