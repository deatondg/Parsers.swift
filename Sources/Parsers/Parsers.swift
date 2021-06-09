@frozen
public enum Parsers {
    public typealias Parser<Output, Failure: Error> = __Parser<Output, Failure>
}
public typealias __Parser<Output, Failure: Error> = Parser<Output, Failure>
