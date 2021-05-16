public struct AllOf1Parser<P0: Parser>: Parser {
    public typealias Stream = P0.Stream
    public typealias Output = P0.Output
    public typealias Failure = OneOf1<P0.Failure>
    
    private let p0: P0
    
    public init(_ p0: P0) {
        self.p0 = p0
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            var index: Stream.Index = index
            let o0: P0.Output
            
            switch p0.parse(stream, index) {
            case .failure(let f0):
                return .failure(.c0(f0))
            case .success(let s0):
                (o0, index) = s0
            }
            
            return .success((o0, index))
        }
    }
}
public struct AllOf2Parser<P0: Parser, P1: Parser>: Parser where P1.Stream == P0.Stream {
    public typealias Stream = P0.Stream
    public typealias Output = (P0.Output, P1.Output)
    public typealias Failure = OneOf2<P0.Failure, P1.Failure>
    
    private let p0: P0
    private let p1: P1
    
    public init(_ p0: P0, _ p1: P1) {
        self.p0 = p0
        self.p1 = p1
    }
    
    public var parse: PrimitiveParser<Stream, Output, Failure> {
        return { stream, index in
            var index: Stream.Index = index
            let o0: P0.Output
            let o1: P1.Output
            
            switch p0.parse(stream, index) {
            case .failure(let f0):
                return .failure(.c0(f0))
            case .success(let s0):
                (o0, index) = s0
            }
            switch p1.parse(stream, index) {
            case .failure(let f1):
                return .failure(.c1(f1))
            case .success(let s1):
                (o1, index) = s1
            }
            
            return .success(((o0, o1), index))
        }
    }
}
public struct AllOf3Parser<P0: Parser, P1: Parser, P2: Parser>: Parser where P1.Stream == P0.Stream, P2.Stream == P0.Stream {
    public typealias Stream = P0.Stream
    public typealias Output = (P0.Output, P1.Output, P2.Output)
    public typealias Failure = OneOf3<P0.Failure, P1.Failure, P2.Failure>
    
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
            var index: Stream.Index = index
            let o0: P0.Output
            let o1: P1.Output
            let o2: P2.Output
            
            switch p0.parse(stream, index) {
            case .failure(let f0):
                return .failure(.c0(f0))
            case .success(let x0):
                (o0, index) = x0
            }
            switch p1.parse(stream, index) {
            case .failure(let f1):
                return .failure(.c1(f1))
            case .success(let x1):
                (o1, index) = x1
            }
            switch p2.parse(stream, index) {
            case .failure(let f2):
                return .failure(.c2(f2))
            case .success(let s2):
                (o2, index) = s2
            }
            
            return .success(((o0, o1, o2), index))
        }
    }
}
public struct AllOf4Parser<P0: Parser, P1: Parser, P2: Parser, P3: Parser>: Parser where P1.Stream == P0.Stream, P2.Stream == P0.Stream, P3.Stream == P0.Stream {
    public typealias Stream = P0.Stream
    public typealias Output = (P0.Output, P1.Output, P2.Output, P3.Output)
    public typealias Failure = OneOf4<P0.Failure, P1.Failure, P2.Failure, P3.Failure>
    
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
            var index: Stream.Index = index
            let o0: P0.Output
            let o1: P1.Output
            let o2: P2.Output
            let o3: P3.Output
            
            switch p0.parse(stream, index) {
            case .failure(let f0):
                return .failure(.c0(f0))
            case .success(let x0):
                (o0, index) = x0
            }
            switch p1.parse(stream, index) {
            case .failure(let f1):
                return .failure(.c1(f1))
            case .success(let x1):
                (o1, index) = x1
            }
            switch p2.parse(stream, index) {
            case .failure(let f2):
                return .failure(.c2(f2))
            case .success(let s2):
                (o2, index) = s2
            }
            switch p3.parse(stream, index) {
            case .failure(let f3):
                return .failure(.c3(f3))
            case .success(let s3):
                (o3, index) = s3
            }
            
            return .success(((o0, o1, o2, o3), index))
        }
    }
}

func AllOf<P0: Parser>(@ParserBuilder ps: () -> P0) -> AllOf1Parser<P0> {
    let ps = ps()
    return .init(ps)
}
func AllOf<P0: Parser, P1: Parser>(@ParserBuilder ps: () -> (P0, P1)) -> AllOf2Parser<P0, P1> where P1.Stream == P0.Stream {
    let ps = ps()
    return .init(ps.0, ps.1)
}
func AllOf<P0: Parser, P1: Parser, P2: Parser>(@ParserBuilder ps: () -> (P0, P1, P2)) -> AllOf3Parser<P0, P1, P2> where P1.Stream == P0.Stream/*, P2.Stream == P0.Stream*/ {
    let ps = ps()
    return .init(ps.0, ps.1, ps.2)
}
func AllOf<P0: Parser, P1: Parser, P2: Parser, P3: Parser>(@ParserBuilder ps: () -> (P0, P1, P2, P3)) -> AllOf4Parser<P0, P1, P2, P3> where P1.Stream == P0.Stream/*, P2.Stream == P0.Stream, P3.Stream == P0.Stream*/ {
    let ps = ps()
    return .init(ps.0, ps.1, ps.2, ps.3)
}

