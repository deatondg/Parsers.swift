public struct OneOf1Parser<P0: Parser>: Parser {
    public typealias Stream = P0.Stream
    public typealias Output = OneOf1<P0.Output>
    public typealias Failure = AllOf1<P0.Failure>
    
    private let p0: P0
    
    public init(_ p0: P0) {
        self.p0 = p0
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            let f0: P0.Failure
            
            switch p0.parse(stream, index) {
            case .failure(let _f0):
                f0 = _f0
            case .success(let (o0, index)):
                return .success((.c0(o0), index))
            }
            
            return .failure(.init(f0))
        }
    }
}
public struct OneOf2Parser<P0: Parser, P1: Parser>: Parser where P1.Stream == P0.Stream {
    public typealias Stream = P0.Stream
    public typealias Output = OneOf2<P0.Output, P1.Output>
    public typealias Failure = AllOf2<P0.Failure, P1.Failure>
    
    private let p0: P0
    private let p1: P1
    
    public init(_ p0: P0, _ p1: P1) {
        self.p0 = p0
        self.p1 = p1
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            let f0: P0.Failure
            let f1: P1.Failure
            
            switch p0.parse(stream, index) {
            case .failure(let _f0):
                f0 = _f0
            case .success(let (o0, index)):
                return .success((.c0(o0), index))
            }
            switch p1.parse(stream, index) {
            case .failure(let _f1):
                f1 = _f1
            case .success(let (o1, index)):
                return .success((.c1(o1), index))
            }
            
            return .failure(.init(f0, f1))
        }
    }
}
public struct OneOf3Parser<P0: Parser, P1: Parser, P2: Parser>: Parser where P1.Stream == P0.Stream, P2.Stream == P0.Stream {
    public typealias Stream = P0.Stream
    public typealias Output = OneOf3<P0.Output, P1.Output, P2.Output>
    public typealias Failure = AllOf3<P0.Failure, P1.Failure, P2.Failure>
    
    private let p0: P0
    private let p1: P1
    private let p2: P2
    
    public init(_ p0: P0, _ p1: P1, _ p2: P2) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            let f0: P0.Failure
            let f1: P1.Failure
            let f2: P2.Failure
            
            switch p0.parse(stream, index) {
            case .failure(let _f0):
                f0 = _f0
            case .success(let (o0, index)):
                return .success((.c0(o0), index))
            }
            switch p1.parse(stream, index) {
            case .failure(let _f1):
                f1 = _f1
            case .success(let (o1, index)):
                return .success((.c1(o1), index))
            }
            switch p2.parse(stream, index) {
            case .failure(let _f2):
                f2 = _f2
            case .success(let (o2, index)):
                return .success((.c2(o2), index))
            }
            
            return .failure(.init(f0, f1, f2))
        }
    }
}
public struct OneOf4Parser<P0: Parser, P1: Parser, P2: Parser, P3: Parser>: Parser where P1.Stream == P0.Stream, P2.Stream == P0.Stream, P3.Stream == P0.Stream {
    public typealias Stream = P0.Stream
    public typealias Output = OneOf4<P0.Output, P1.Output, P2.Output, P3.Output>
    public typealias Failure = AllOf4<P0.Failure, P1.Failure, P2.Failure, P3.Failure>
    
    private let p0: P0
    private let p1: P1
    private let p2: P2
    private let p3: P3
    
    public init(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            let f0: P0.Failure
            let f1: P1.Failure
            let f2: P2.Failure
            let f3: P3.Failure
            
            switch p0.parse(stream, index) {
            case .failure(let _f0):
                f0 = _f0
            case .success(let (o0, index)):
                return .success((.c0(o0), index))
            }
            switch p1.parse(stream, index) {
            case .failure(let _f1):
                f1 = _f1
            case .success(let (o1, index)):
                return .success((.c1(o1), index))
            }
            switch p2.parse(stream, index) {
            case .failure(let _f2):
                f2 = _f2
            case .success(let (o2, index)):
                return .success((.c2(o2), index))
            }
            switch p3.parse(stream, index) {
            case .failure(let _f3):
                f3 = _f3
            case .success(let (o3, index)):
                return .success((.c3(o3), index))
            }
            
            return .failure(.init(f0, f1, f2, f3))
        }
    }
}

public func OneOf<P0: Parser>(@ParserBuilder ps: () -> P0) -> OneOf1Parser<P0> {
    let ps = ps()
    return .init(ps)
}
public func OneOf<P0: Parser, P1: Parser>(@ParserBuilder ps: () -> (P0, P1)) -> OneOf2Parser<P0, P1> where P1.Stream == P0.Stream {
    let ps = ps()
    return .init(ps.0, ps.1)
}
public func OneOf<P0: Parser, P1: Parser, P2: Parser>(@ParserBuilder ps: () -> (P0, P1, P2)) -> OneOf3Parser<P0, P1, P2> where P1.Stream == P0.Stream/*, P2.Stream == P0.Stream*/ {
    let ps = ps()
    return .init(ps.0, ps.1, ps.2)
}
public func OneOf<P0: Parser, P1: Parser, P2: Parser, P3: Parser>(@ParserBuilder ps: () -> (P0, P1, P2, P3)) -> OneOf4Parser<P0, P1, P2, P3> where P1.Stream == P0.Stream/*, P2.Stream == P0.Stream, P3.Stream == P0.Stream*/ {
    let ps = ps()
    return .init(ps.0, ps.1, ps.2, ps.3)
}
