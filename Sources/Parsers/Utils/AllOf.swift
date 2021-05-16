public struct AllOf1<T0> {
    public let v0: T0
    
    public init(_ v0: T0) {
        self.v0 = v0
    }
    
    public func asTuple() -> T0 {
        v0
    }
}
public struct AllOf2<T0, T1> {
    public let v0: T0
    public let v1: T1
    
    public init(_ v0: T0, _ v1: T1) {
        self.v0 = v0
        self.v1 = v1
    }
    public init(_ v: (T0, T1)) {
        self.v0 = v.0
        self.v1 = v.1
    }
    
    public func asTuple() -> (T0, T1) {
        (v0, v1)
    }
}
public struct AllOf3<T0, T1, T2> {
    public let v0: T0
    public let v1: T1
    public let v2: T2
    
    public init(_ v0: T0, _ v1: T1, _ v2: T2) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
    }
    public init(_ v: (T0, T1, T2)) {
        self.v0 = v.0
        self.v1 = v.1
        self.v2 = v.2
    }
    
    public func asTuple() -> (T0, T1, T2) {
        (v0, v1, v2)
    }
}
public struct AllOf4<T0, T1, T2, T3> {
    public let v0: T0
    public let v1: T1
    public let v2: T2
    public let v3: T3
    
    public init(_ v0: T0, _ v1: T1, _ v2: T2, _ v3: T3) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
    }
    public init(_ v: (T0, T1, T2, T3)) {
        self.v0 = v.0
        self.v1 = v.1
        self.v2 = v.2
        self.v3 = v.3
    }
    
    public func asTuple() -> (T0, T1, T2, T3) {
        (v0, v1, v2, v3)
    }
}

extension AllOf1: Error where T0: Error {}
extension AllOf2: Error where T0: Error, T1: Error {}
extension AllOf3: Error where T0: Error, T1: Error, T2: Error {}
extension AllOf4: Error where T0: Error, T1: Error, T2: Error, T3: Error {}
