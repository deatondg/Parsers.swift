public struct RemainderParser<Stream: Collection>: Parser {
    public typealias Output = Stream.SubSequence
    public typealias Failure = Never
    
    public init() {}
    
    public var parse: PrimitiveParser<Stream, Stream.SubSequence, Never> {
        return { (stream, index) in
            return .success((stream[index...], stream.endIndex))
        }
    }
}
