@frozen
public enum AllOf1Failure<O0, F0: Error>: Error {
    case f0(F0)
}
@frozen
public enum AllOf2Failure<O0, F0: Error, O1, F1: Error>: Error {
    case f0(F0)
    case f1(F1, O0)
}
@frozen
public enum AllOf3Failure<O0, F0: Error, O1, F1: Error, O2, F2: Error>: Error {
    case f0(F0)
    case f1(F1, O0)
    case f2(F2, O0, O1)
}
@frozen
public enum AllOf4Failure<O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>: Error {
    case f0(F0)
    case f1(F1, O0)
    case f2(F2, O0, O1)
    case f3(F3, O0, O1, O2)
}

struct AllOf1Parser<O0, F0: Error>: ParserProtocol {
    typealias Output = O0
    typealias Failure = AllOf1Failure<O0, F0>
    
    let p0: Parser<O0, F0>
    
    init(_ p0: Parser<O0, F0>) {
        self.p0 = p0
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: O0, endIndex: String.Index), AllOf1Failure<O0, F0>> {
        var index: String.Index = index
        let o0: O0
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let f0):
            return .failure(.f0(f0))
        case .success(let x0):
            (o0, index) = x0
        }
        
        return .success((o0, index))
    }
}
struct AllOf2Parser<O0, F0: Error, O1, F1: Error>: ParserProtocol {
    typealias Output = (O0, O1)
    typealias Failure = AllOf2Failure<O0, F0, O1, F1>
    
    let p0: Parser<O0, F0>
    let p1: Parser<O1, F1>
    
    init(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>) {
        self.p0 = p0
        self.p1 = p1
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: (O0, O1), endIndex: String.Index), AllOf2Failure<O0, F0, O1, F1>> {
        var index: String.Index = index
        let o0: O0
        let o1: O1
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let f0):
            return .failure(.f0(f0))
        case .success(let x0):
            (o0, index) = x0
        }
        switch p1.parse(from: string, startingAt: index) {
        case .failure(let f1):
            return .failure(.f1(f1, o0))
        case .success(let x1):
            (o1, index) = x1
        }
        
        return .success(((o0, o1), index))
    }
}
struct AllOf3Parser<O0, F0: Error, O1, F1: Error, O2, F2: Error>: ParserProtocol {
    typealias Output = (O0, O1, O2)
    typealias Failure = AllOf3Failure<O0, F0, O1, F1, O2, F2>
    
    let p0: Parser<O0, F0>
    let p1: Parser<O1, F1>
    let p2: Parser<O2, F2>
    
    init(_ p0: Parser<O0, F0>, _ p1: Parser<O1, F1>, _ p2: Parser<O2, F2>) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: (O0, O1, O2), endIndex: String.Index), AllOf3Failure<O0, F0, O1, F1, O2, F2>> {
        var index: String.Index = index
        let o0: O0
        let o1: O1
        let o2: O2
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let f0):
            return .failure(.f0(f0))
        case .success(let x0):
            (o0, index) = x0
        }
        switch p1.parse(from: string, startingAt: index) {
        case .failure(let f1):
            return .failure(.f1(f1, o0))
        case .success(let x1):
            (o1, index) = x1
        }
        switch p2.parse(from: string, startingAt: index) {
        case .failure(let f2):
            return .failure(.f2(f2, o0, o1))
        case .success(let s2):
            (o2, index) = s2
        }
        
        return .success(((o0, o1, o2), index))
    }
}
struct AllOf4Parser<O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>: ParserProtocol {
    typealias Output = (O0, O1, O2, O3)
    typealias Failure = AllOf4Failure<O0, F0, O1, F1, O2, F2, O3, F3>
    
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
    
    func parse(from string: String, startingAt index: String.Index) -> Result<(value: (O0, O1, O2, O3), endIndex: String.Index), AllOf4Failure<O0, F0, O1, F1, O2, F2, O3, F3>> {
        var index: String.Index = index
        let o0: O0
        let o1: O1
        let o2: O2
        let o3: O3
        
        switch p0.parse(from: string, startingAt: index) {
        case .failure(let f0):
            return .failure(.f0(f0))
        case .success(let x0):
            (o0, index) = x0
        }
        switch p1.parse(from: string, startingAt: index) {
        case .failure(let f1):
            return .failure(.f1(f1, o0))
        case .success(let x1):
            (o1, index) = x1
        }
        switch p2.parse(from: string, startingAt: index) {
        case .failure(let f2):
            return .failure(.f2(f2, o0, o1))
        case .success(let s2):
            (o2, index) = s2
        }
        switch p3.parse(from: string, startingAt: index) {
        case .failure(let f3):
            return .failure(.f3(f3, o0, o1, o2))
        case .success(let s3):
            (o3, index) = s3
        }
        
        return .success(((o0, o1, o2, o3), index))
    }
}

public func AllOf<O0, F0: Error>(@ParserBuilder ps: () -> Parser<O0, F0>) -> Parser<O0, AllOf1Failure<O0, F0>> {
    let ps = ps()
    return AllOf1Parser(ps).eraseToParser()
}
public func AllOf<O0, F0: Error, O1, F1: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>, Parser<O1, F1>)) -> Parser<(O0, O1), AllOf2Failure<O0, F0, O1, F1>> {
    let ps = ps()
    return AllOf2Parser(ps.0, ps.1).eraseToParser()
}
public func AllOf<O0, F0: Error, O1, F1: Error, O2, F2: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>, Parser<O1, F1>, Parser<O2, F2>)) -> Parser<(O0, O1, O2), AllOf3Failure<O0, F0, O1, F1, O2, F2>> {
    let ps = ps()
    return AllOf3Parser(ps.0, ps.1, ps.2).eraseToParser()
}
public func AllOf<O0, F0: Error, O1, F1: Error, O2, F2: Error, O3, F3: Error>(@ParserBuilder ps: () -> (Parser<O0, F0>, Parser<O1, F1>, Parser<O2, F2>, Parser<O3, F3>)) -> Parser<(O0, O1, O2, O3), AllOf4Failure<O0, F0, O1, F1, O2, F2, O3, F3>> {
    let ps = ps()
    return AllOf4Parser(ps.0, ps.1, ps.2, ps.3).eraseToParser()
}
