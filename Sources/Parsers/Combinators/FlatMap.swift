@frozen
public enum FlatMapParserFailure<OuterFailure: Error, MapFailure: Error, InnerFailure: Error>: Error {
    case outerFailure(OuterFailure)
    case mapFailure(MapFailure)
    case innerFailure(InnerFailure)
}

struct FFlatFMapFParser<OuterOutput, OuterFailure: Error, MapParser: ParserProtocol, MapFailure: Error>: ParserProtocol {
    typealias Output = MapParser.Output
    typealias Failure = FlatMapParserFailure<OuterFailure, MapFailure, MapParser.Failure>
    
    let p: Parser<OuterOutput, OuterFailure>
    let f: (OuterOutput) -> Result<MapParser, MapFailure>
    
    init(_ p: Parser<OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) -> Result<MapParser, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) throws -> MapParser) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapParser.Output, endIndex: String.Index), FlatMapParserFailure<OuterFailure, MapFailure, MapParser.Failure>> {
        switch p.parse(from: string, startingAt:  index) {
        case .failure(let outerFailure):
            return .failure(.outerFailure(outerFailure))
        case .success(let (outerOutput, index)):
            switch f(outerOutput) {
            case .failure(let mapFailure):
                return .failure(.mapFailure(mapFailure))
            case .success(let mapParser):
                switch mapParser.parse(from: string, startingAt: index) {
                case .failure(let innerFailure):
                    return .failure(.innerFailure(innerFailure))
                case .success(let (innerOutput, index)):
                    return .success((innerOutput, index))
                }
            }
        }
    }
}

struct FFlatMapFParser<OuterOutput, OuterFailure: Error, MapParser: ParserProtocol>: ParserProtocol {
    typealias Output = MapParser.Output
    typealias Failure = FlatMapParserFailure<OuterFailure, Never, MapParser.Failure>
    
    let p: Parser< OuterOutput, OuterFailure>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser< OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapParser.Output, endIndex: String.Index), FlatMapParserFailure<OuterFailure, Never, MapParser.Failure>> {
        switch p.parse(from: string, startingAt:  index) {
        case .failure(let outerFailure):
            return .failure(.outerFailure(outerFailure))
        case .success(let (outerOutput, index)):
            switch f(outerOutput).parse(from: string, startingAt: index) {
            case .failure(let innerFailure):
                return .failure(.innerFailure(innerFailure))
            case .success(let (innerOutput, index)):
                return .success((innerOutput, index))
            }
        }
    }
}

struct FlatMapFParser< OuterOutput, OuterFailure: Error, MapParser: ParserProtocol>: ParserProtocol where MapParser.Failure == Never {
    typealias Output = MapParser.Output
    typealias Failure = OuterFailure
    
    let p: Parser<OuterOutput, OuterFailure>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapParser.Output, endIndex: String.Index), OuterFailure> {
        switch p.parse(from: string, startingAt:  index) {
        case .failure(let outerFailure):
            return .failure(outerFailure)
        case .success(let (outerOutput, index)):
            return .success(f(outerOutput).parse(from: string, startingAt: index))
        }
    }
}

struct FlatFMapParser<OuterOutput, MapParser: ParserProtocol, MapFailure: Error>: ParserProtocol where MapParser.Failure == Never {
    typealias Output = MapParser.Output
    typealias Failure = MapFailure
    
    let p: Parser<OuterOutput, Never>
    let f: (OuterOutput) -> Result<MapParser, MapFailure>
    
    init(_ p: Parser<OuterOutput, Never>, _ f: @escaping (OuterOutput) -> Result<MapParser, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<OuterOutput, Never>, _ f: @escaping (OuterOutput) throws -> MapParser) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapParser.Output, endIndex: String.Index), MapFailure> {
        let (outerOutput, index) = p.parse(from: string, startingAt:  index)
        switch f(outerOutput) {
        case .failure(let mapFailure):
            return .failure(mapFailure)
        case .success(let mapParser):
            return .success(mapParser.parse(from: string, startingAt: index))
        }
    }
}

struct FFlatMapParser<OuterOutput, MapParser: ParserProtocol>: ParserProtocol {
    typealias Output = MapParser.Output
    typealias Failure = MapParser.Failure
    
    let p: Parser<OuterOutput, Never>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<OuterOutput, Never>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapParser.Output, endIndex: String.Index), MapParser.Failure> {
        let (outerOutput, index) = p.parse(from: string, startingAt:  index)
        return f(outerOutput).parse(from: string, startingAt: index)
    }
}

struct FlatMapParser<OuterOutput, MapParser: ParserProtocol>: ParserProtocol where MapParser.Failure == Never {
    typealias Output = MapParser.Output
    typealias Failure = Never
    
    let p: Parser<OuterOutput, Never>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<OuterOutput, Never>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: MapParser.Output, endIndex: String.Index), Never> {
        let (outerOutput, index) = p.parse(from: string, startingAt:  index)
        return .success(f(outerOutput).parse(from: string, startingAt: index))
    }
}

public extension Parser {
    func flatMap<MapParser: ParserProtocol, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> Parser<MapParser.Output, FlatMapParserFailure<Failure, MapFailure, MapParser.Failure>> {
        FFlatFMapFParser(self, f).parser
    }
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) throws -> MapParser) -> Parser<MapParser.Output, FlatMapParserFailure<Failure, Error, MapParser.Failure>> {
        FFlatFMapFParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<MapParser.Output, FlatMapParserFailure<Failure, Never, MapParser.Failure>> {
        FFlatMapFParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<MapParser.Output, Failure> where MapParser.Failure == Never {
        FlatMapFParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> Parser<MapParser.Output, MapFailure> where MapParser.Failure == Never, Failure == Never {
        FlatFMapParser(self, f).parser
    }
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) throws -> MapParser) -> Parser<MapParser.Output, Error> where MapParser.Failure == Never, Failure == Never {
        FlatFMapParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<MapParser.Output, MapParser.Failure> where Failure == Never {
        FFlatMapParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<MapParser.Output, Never> where MapParser.Failure == Never, Failure == Never {
        FlatMapParser(self, f).parser
    }
}
