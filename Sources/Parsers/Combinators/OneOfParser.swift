struct OneOf1Parser<O0, F0: Error>: ParserProtocol {
    typealias Output = OneOf1<O0>
    typealias Failure = AllOf1<F0>
    
    let p0: Parser<O0, F0>
    
    init(_ p0: Parser<O0, F0>) {
        self.p0 = p0
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OneOf1<O0>, endIndex: String.Index), AllOf1<F0>> {
        let f0: F0
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let _f0):
            f0 = _f0
        case .success(let (o0, index)):
            return .success((.c0(o0), index))
        }
        
        return .failure(.init(f0))
    }
}
struct OneOf2Parser<O0, F0: Error, O1, F1: Error>: ParserProtocol {
    typealias Output = OneOf2<O0, O1>
    typealias Failure = AllOf2<F0, F1>
    
    let p0: Parser<O0, F0>
    let p1: Parser<O1, F1>
    
    init(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>) {
        self.p0 = p0
        self.p1 = p1
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OneOf2<O0, O1>, endIndex: String.Index), AllOf2<F0, F1>> {
        let f0: F0
        let f1: F1
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let _f0):
            f0 = _f0
        case .success(let (o0, index)):
            return .success((.c0(o0), index))
        }
        switch p1.parse(from: string, startingAt: index) {
        case .failure(let _f1):
            f1 = _f1
        case .success(let (o1, index)):
            return .success((.c1(o1), index))
        }
        
        return .failure(.init(f0, f1))
    }
}
struct OneOf3Parser<O0, F0: Error, O1, F1: Error, O2, F2: Error>: ParserProtocol {
    typealias Output = OneOf3<O0, O1, O2>
    typealias Failure = AllOf3<F0, F1, F2>
    
    let p0: Parser<O0, F0>
    let p1: Parser<O1, F1>
    let p2: Parser<O2, F2>
    
    init(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>, _ p2: Parser<O2, F2>) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OneOf3<O0, O1, O2>, endIndex: String.Index), AllOf3<F0, F1, F2>> {
        let f0: F0
        let f1: F1
        let f2: F2
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let _f0):
            f0 = _f0
        case .success(let (o0, index)):
            return .success((.c0(o0), index))
        }
        switch p1.parse(from: string, startingAt: index) {
        case .failure(let _f1):
            f1 = _f1
        case .success(let (o1, index)):
            return .success((.c1(o1), index))
        }
        switch p2.parse(from: string, startingAt: index) {
        case .failure(let _f2):
            f2 = _f2
        case .success(let (o2, index)):
            return .success((.c2(o2), index))
        }
        
        return .failure(.init(f0, f1, f2))
    }
}
struct OneOf4Parser<O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>: ParserProtocol {
    typealias Output = OneOf4<O0, O1, O2, O3>
    typealias Failure = AllOf4<F0, F1, F2, F3>
    
    let p0: Parser<O0, F0>
    let p1: Parser<O1, F1>
    let p2: Parser<O2, F2>
    let p3: Parser<O3, F3>
    
    init(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>, _ p2: Parser<O2, F2>, _ p3: Parser<O3, F3>) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: OneOf4<O0, O1, O2, O3>, endIndex: String.Index), AllOf4<F0, F1, F2, F3>> {
        let f0: F0
        let f1: F1
        let f2: F2
        let f3: F3
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let _f0):
            f0 = _f0
        case .success(let (o0, index)):
            return .success((.c0(o0), index))
        }
        switch p1.parse(from: string, startingAt: index) {
        case .failure(let _f1):
            f1 = _f1
        case .success(let (o1, index)):
            return .success((.c1(o1), index))
        }
        switch p2.parse(from: string, startingAt: index) {
        case .failure(let _f2):
            f2 = _f2
        case .success(let (o2, index)):
            return .success((.c2(o2), index))
        }
        switch p3.parse(from: string, startingAt: index) {
        case .failure(let _f3):
            f3 = _f3
        case .success(let (o3, index)):
            return .success((.c3(o3), index))
        }
        
        return .failure(.init(f0, f1, f2, f3))
    }
}

public func OneOf<O0, F0: Error>(@ParserBuilder ps: () -> Parser<O0, F0>) -> Parser<OneOf1<O0>, AllOf1<F0>> {
    let ps = ps()
    return OneOf1Parser(ps).eraseToParser()
}
public func OneOf<O0, F0: Error, O1, F1: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>, Parser<O1, F1>)) -> Parser<OneOf2<O0, O1>, AllOf2<F0, F1>> {
    let ps = ps()
    return OneOf2Parser(ps.0, ps.1).eraseToParser()
}
public func OneOf<O0, F0: Error, O1, F1: Error, O2, F2: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>, Parser<O1, F1>, Parser<O2, F2>)) -> Parser<OneOf3<O0, O1, O2>, AllOf3<F0, F1, F2>> {
    let ps = ps()
    return OneOf3Parser(ps.0, ps.1, ps.2).eraseToParser()
}
public func OneOf<O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>, Parser<O1, F1>, Parser<O2, F2>, Parser<O3, F3>)) -> Parser<OneOf4<O0, O1, O2, O3>, AllOf4<F0, F1, F2, F3>> {
    let ps = ps()
    return OneOf4Parser(ps.0, ps.1, ps.2, ps.3).eraseToParser()
}

//public func OneOf<O0, F0: Error, O1, F1: Error, O2, F2: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>?, Parser<O1, F1>?, Parser<O2, F2>)) -> Parser<OneOf3<O0, O1, O2>, AllOf3<F0?, F1?, F2>> {
//    let ps = ps()
//
//    let p0: Parser<O0, F0?> = ps.0.orFailParser()
//    let p1: Parser<O1, F1?> = ps.1.orFailParser()
//    let p2: Parser<O2, F2> = ps.2
//
//    let r: Parser<OneOf3<O0, O1, O2>, AllOf3<F0?, F1?, F2>> = OneOf3Parser(p0, p1, p2).eraseToParser()
//
//    fatalError()
//}
