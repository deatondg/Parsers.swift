public struct PrefixParser<Stream: Collection, PossiblePrefix: Collection>: Parser where Stream.Element: Equatable, PossiblePrefix.Element == Stream.Element {
    
    public typealias Output = Stream.SubSequence
    public enum Failure: Error {
        case noMatch
    }
    
    private let p: PossiblePrefix
    
    public init(_ p: PossiblePrefix) {
        self.p = p
    }
    public init(_ p: Stream.Element) where PossiblePrefix == CollectionOfOne<Stream.Element> {
        self.p = CollectionOfOne(p)
    }
    public init(_ p: PossiblePrefix, stream: Stream.Type) {
        self.p = p
    }
    public init(_ p: Stream.Element, stream: Stream.Type) where PossiblePrefix == CollectionOfOne<Stream.Element> {
        self.p = CollectionOfOne(p)
    }
    
    public var parse: PrimitiveParser<Stream, Stream.SubSequence, Failure> {
        return { stream, startIndex in
            if stream[startIndex...].starts(with: p) {
                let endIndex = stream.index(startIndex, offsetBy: p.count)
                return .success((stream[startIndex..<endIndex], endIndex))
            } else {
                return .failure(.noMatch)
            }
        }
    }
}
public extension Parsers {
    static func prefix<Stream: Collection, PossiblePrefix: Collection>(_ p: PossiblePrefix) -> PrefixParser<Stream, PossiblePrefix> where Stream.Element: Equatable, PossiblePrefix.Element == Stream.Element {
        .init(p)
    }
    static func prefix<Stream: Collection, PossiblePrefix: Collection>(_ p: PossiblePrefix, stream: Stream.Type) -> PrefixParser<Stream, PossiblePrefix> where Stream.Element: Equatable, PossiblePrefix.Element == Stream.Element {
        .init(p)
    }
}
