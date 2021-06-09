public extension Parsers {
    static func fatalError<T>(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> T {
        Swift.fatalError(message(), file: file, line: line)
    }
}

