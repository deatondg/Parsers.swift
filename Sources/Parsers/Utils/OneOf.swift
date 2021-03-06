@frozen public enum OneOf1<T0> {
    case c0(T0)
}
@frozen public enum OneOf2<T0, T1> {
    case c0(T0)
    case c1(T1)
}
@frozen public enum OneOf3<T0, T1, T2> {
    case c0(T0)
    case c1(T1)
    case c2(T2)
}
@frozen public enum OneOf4<T0, T1, T2, T3> {
    case c0(T0)
    case c1(T1)
    case c2(T2)
    case c3(T3)
}

extension OneOf1: Error where T0: Error {}
extension OneOf2: Error where T0: Error, T1: Error {}
extension OneOf3: Error where T0: Error, T1: Error, T2: Error {}
extension OneOf4: Error where T0: Error, T1: Error, T2: Error, T3: Error {}

public extension OneOf1 {
    func ignoreCases() -> T0 {
        switch self {
        case .c0(let v):
            return v
        }
    }
}
public extension OneOf2 where T1 == T0 {
    func ignoreCases() -> T0 {
        switch self {
        case .c0(let v),
             .c1(let v):
            return v
        }
    }
}
public extension OneOf3 where T1 == T0, T2 == T0 {
    func ignoreCases() -> T0 {
        switch self {
        case .c0(let v),
             .c1(let v),
             .c2(let v):
            return v
        }
    }
}
public extension OneOf4 where T1 == T0, T2 == T0, T3 == T0 {
    func ignoreCases() -> T0 {
        switch self {
        case .c0(let v),
             .c1(let v),
             .c2(let v),
             .c3(let v):
            return v
        }
    }
}
