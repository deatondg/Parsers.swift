@resultBuilder
@frozen public enum ParserBuilder {
    public static func buildBlock<P: Parser>(_ p: P) -> PrimitiveParser<P.Stream, P.Output, P.Failure> {
        p.parse
    }
    
    public static func buildBlock<P0: Parser>(_ p0: P0) -> P0 {
        p0
    }
    public static func buildBlock<P0: Parser, P1: Parser>(_ p0: P0, _ p1: P1) -> (P0, P1) where P1.Stream == P0.Stream {
        (p0, p1)
    }
    public static func buildBlock<P0: Parser, P1: Parser, P2: Parser>(_ p0: P0, _ p1: P1, _ p2: P2) -> (P0, P1, P2) where P1.Stream == P0.Stream, P2.Stream == P0.Stream {
        (p0, p1, p2)
    }
    public static func buildBlock<P0: Parser, P1: Parser, P2: Parser, P3: Parser>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3) -> (P0, P1, P2, P3) where P1.Stream == P0.Stream, P2.Stream == P0.Stream, P3.Stream == P0.Stream {
        (p0, p1, p2, p3)
    }
}
