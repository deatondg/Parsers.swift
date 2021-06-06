@frozen
public enum FlatMapParserFailure<OuterFailure: Error, MapFailure: Error, InnerFailure: Error>: Error {
    case outerFailure(OuterFailure)
    case mapFailure(MapFailure)
    case innerFailure(InnerFailure)
}

struct FFlatFMapFParser<Stream, OuterOutput, OuterFailure: Error, MapParser: ParserProtocol, MapFailure: Error>: ParserProtocol where MapParser.Stream == Stream {
    typealias Output = MapParser.Output
    typealias Failure = FlatMapParserFailure<OuterFailure, MapFailure, MapParser.Failure>
    
    let p: Parser<Stream, OuterOutput, OuterFailure>
    let f: (OuterOutput) -> Result<MapParser, MapFailure>
    
    init(_ p: Parser<Stream, OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) -> Result<MapParser, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<Stream, OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) throws -> MapParser) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapParser.Output, endIndex: Stream.Index), FlatMapParserFailure<OuterFailure, MapFailure, MapParser.Failure>> {
        switch p.parse(from: stream, startingAt:  index) {
        case .failure(let outerFailure):
            return .failure(.outerFailure(outerFailure))
        case .success(let (outerOutput, index)):
            switch f(outerOutput) {
            case .failure(let mapFailure):
                return .failure(.mapFailure(mapFailure))
            case .success(let mapParser):
                switch mapParser.parse(from: stream, startingAt: index) {
                case .failure(let innerFailure):
                    return .failure(.innerFailure(innerFailure))
                case .success(let (innerOutput, index)):
                    return .success((innerOutput, index))
                }
            }
        }
    }
}

struct FFlatMapFParser<Stream, OuterOutput, OuterFailure: Error, MapParser: ParserProtocol>: ParserProtocol where MapParser.Stream == Stream {
    typealias Output = MapParser.Output
    typealias Failure = FlatMapParserFailure<OuterFailure, Never, MapParser.Failure>
    
    let p: Parser<Stream, OuterOutput, OuterFailure>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<Stream, OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapParser.Output, endIndex: Stream.Index), FlatMapParserFailure<OuterFailure, Never, MapParser.Failure>> {
        switch p.parse(from: stream, startingAt:  index) {
        case .failure(let outerFailure):
            return .failure(.outerFailure(outerFailure))
        case .success(let (outerOutput, index)):
            switch f(outerOutput).parse(from: stream, startingAt: index) {
            case .failure(let innerFailure):
                return .failure(.innerFailure(innerFailure))
            case .success(let (innerOutput, index)):
                return .success((innerOutput, index))
            }
        }
    }
}

struct FlatMapFParser<Stream, OuterOutput, OuterFailure: Error, MapParser: ParserProtocol>: ParserProtocol where MapParser.Stream == Stream, MapParser.Failure == Never {
    typealias Output = MapParser.Output
    typealias Failure = OuterFailure
    
    let p: Parser<Stream, OuterOutput, OuterFailure>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<Stream, OuterOutput, OuterFailure>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapParser.Output, endIndex: Stream.Index), OuterFailure> {
        switch p.parse(from: stream, startingAt:  index) {
        case .failure(let outerFailure):
            return .failure(outerFailure)
        case .success(let (outerOutput, index)):
            return .success(f(outerOutput).parse(from: stream, startingAt: index))
        }
    }
}

struct FlatFMapParser<Stream, OuterOutput, MapParser: ParserProtocol, MapFailure: Error>: ParserProtocol where MapParser.Stream == Stream, MapParser.Failure == Never {
    typealias Output = MapParser.Output
    typealias Failure = MapFailure
    
    let p: Parser<Stream, OuterOutput, Never>
    let f: (OuterOutput) -> Result<MapParser, MapFailure>
    
    init(_ p: Parser<Stream, OuterOutput, Never>, _ f: @escaping (OuterOutput) -> Result<MapParser, MapFailure>) {
        self.p = p
        self.f = f
    }
    init(_ p: Parser<Stream, OuterOutput, Never>, _ f: @escaping (OuterOutput) throws -> MapParser) where MapFailure == Error {
        self.p = p
        self.f = {
            do {
                return .success(try f($0))
            } catch {
                return .failure(error)
            }
        }
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapParser.Output, endIndex: Stream.Index), MapFailure> {
        let (outerOutput, index) = p.parse(from: stream, startingAt:  index)
        switch f(outerOutput) {
        case .failure(let mapFailure):
            return .failure(mapFailure)
        case .success(let mapParser):
            return .success(mapParser.parse(from: stream, startingAt: index))
        }
    }
}

struct FFlatMapParser<Stream, OuterOutput, MapParser: ParserProtocol>: ParserProtocol where MapParser.Stream == Stream {
    typealias Output = MapParser.Output
    typealias Failure = MapParser.Failure
    
    let p: Parser<Stream, OuterOutput, Never>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<Stream, OuterOutput, Never>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapParser.Output, endIndex: Stream.Index), MapParser.Failure> {
        let (outerOutput, index) = p.parse(from: stream, startingAt:  index)
        return f(outerOutput).parse(from: stream, startingAt: index)
    }
}

struct FlatMapParser<Stream, OuterOutput, MapParser: ParserProtocol>: ParserProtocol where MapParser.Stream == Stream, MapParser.Failure == Never {
    typealias Output = MapParser.Output
    typealias Failure = Never
    
    let p: Parser<Stream, OuterOutput, Never>
    let f: (OuterOutput) -> MapParser
    
    init(_ p: Parser<Stream, OuterOutput, Never>, _ f: @escaping (OuterOutput) -> MapParser) {
        self.p = p
        self.f = f
    }
    
    func parse(from stream: Stream, startingAt index: Stream.Index) -> Result<(value: MapParser.Output, endIndex: Stream.Index), Never> {
        let (outerOutput, index) = p.parse(from: stream, startingAt:  index)
        return .success(f(outerOutput).parse(from: stream, startingAt: index))
    }
}

public extension Parser {
    func flatMap<MapParser: ParserProtocol, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> Parser<Stream, MapParser.Output, FlatMapParserFailure<Failure, MapFailure, MapParser.Failure>> where MapParser.Stream == Stream {
        FFlatFMapFParser(self, f).parser
    }
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) throws -> MapParser) -> Parser<Stream, MapParser.Output, FlatMapParserFailure<Failure, Error, MapParser.Failure>> where MapParser.Stream == Stream {
        FFlatFMapFParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<Stream, MapParser.Output, FlatMapParserFailure<Failure, Never, MapParser.Failure>> where MapParser.Stream == Stream {
        FFlatMapFParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<Stream, MapParser.Output, Failure> where MapParser.Stream == Stream, MapParser.Failure == Never {
        FlatMapFParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol, MapFailure: Error>(_ f: @escaping (Output) -> Result<MapParser, MapFailure>) -> Parser<Stream, MapParser.Output, MapFailure> where MapParser.Stream == Stream, MapParser.Failure == Never, Failure == Never {
        FlatFMapParser(self, f).parser
    }
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) throws -> MapParser) -> Parser<Stream, MapParser.Output, Error> where MapParser.Stream == Stream, MapParser.Failure == Never, Failure == Never {
        FlatFMapParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<Stream, MapParser.Output, MapParser.Failure> where MapParser.Stream == Stream, Failure == Never {
        FFlatMapParser(self, f).parser
    }
    
    func flatMap<MapParser: ParserProtocol>(_ f: @escaping (Output) -> MapParser) -> Parser<Stream, MapParser.Output, Never> where MapParser.Stream == Stream, MapParser.Failure == Never, Failure == Never {
        FlatMapParser(self, f).parser
    }
}
