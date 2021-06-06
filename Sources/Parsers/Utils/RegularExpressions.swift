import Foundation

public extension NSRange {
    init(_: UnboundedRange, in string: String) {
        self.init(string.startIndex..<string.endIndex, in: string)
    }
}
public extension StringProtocol {
    subscript(_ range: NSRange) -> SubSequence? {
        Range(range, in: self).map({ self[$0] })
    }
}

public struct RegularExpressionMatch: RandomAccessCollection {
    public let string: String
    public let result: NSTextCheckingResult
    
    public enum RegularExpressionMatchError: Error {
        case invalidType(NSTextCheckingResult.CheckingType)
    }
    public init(_ result: NSTextCheckingResult, in string: String) throws {
        guard result.resultType == .regularExpression else {
            throw RegularExpressionMatchError.invalidType(result.resultType)
        }
        self.init(unchecked: result, in: string)
    }
    public init(unchecked result: NSTextCheckingResult, in string: String) {
        self.string = string
        self.result = result
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { result.numberOfRanges }
    public func index(after i: Int) -> Int { i + 1 }
    
    // TODO: Is this safe?
    public var match: Substring {
        string[result.range]!
    }
    public subscript(position: Int) -> Substring? {
        string[result.range(at: position)]
    }
    public subscript(name name: String) -> Substring? {
        string[result.range(withName: name)]
    }
    // TODO: Is this safe?
    public var range: Range<String.Index> {
        Range(result.range, in: string)!
    }
    public func range(at position: Int) -> Range<String.Index>? {
        Range(result.range(at: position), in: string)
    }
    public func range(named name: String) -> Range<String.Index>? {
        Range(result.range(withName: name), in: string)
    }
}

public extension NSRegularExpression {
    func numberOfMatches<R: RangeExpression>(in string: String, options: NSRegularExpression.MatchingOptions, range: R) -> Int where R.Bound == String.Index {
        self.numberOfMatches(in: string, options: options, range: NSRange(range, in: string))
    }
    func numberOfMatches(in string: String, options: NSRegularExpression.MatchingOptions, range: UnboundedRange) -> Int {
        self.numberOfMatches(in: string, options: options, range: NSRange(range, in: string))
    }
    
    func enumerateMatches<R: RangeExpression>(
        in string: String,
        options: NSRegularExpression.MatchingOptions,
        range: R,
        using block: (RegularExpressionMatch?, NSRegularExpression.MatchingFlags, inout Bool) -> ()
    ) where R.Bound == String.Index {
        self.enumerateMatches(in: string, options: options, range: NSRange(range, in: string), using: { (match, flags, stop) in
            var shouldStop: Bool = stop.pointee.boolValue
            block(match.map({ RegularExpressionMatch(unchecked: $0, in: string) }), flags, &shouldStop)
            if shouldStop {
                stop.pointee = true
            }
        })
    }
    func enumerateMatches(
        in string: String,
        options: NSRegularExpression.MatchingOptions,
        range: UnboundedRange,
        using block: (RegularExpressionMatch?, NSRegularExpression.MatchingFlags, inout Bool) -> ()
    ) {
        self.enumerateMatches(in: string, options: options, range: NSRange(range, in: string), using: { (match, flags, stop) in
            var shouldStop: Bool = stop.pointee.boolValue
            block(match.map({ RegularExpressionMatch(unchecked: $0, in: string) }), flags, &shouldStop)
            if shouldStop {
                stop.pointee = true
            }
        })
    }
    
    func matches<R: RangeExpression>(in string: String, options: NSRegularExpression.MatchingOptions, range: R) -> [RegularExpressionMatch] where R.Bound == String.Index {
        self.matches(in: string, options: options, range: NSRange(range, in: string)).map({ RegularExpressionMatch(unchecked: $0, in: string) })
    }
    func matches(in string: String, options: NSRegularExpression.MatchingOptions, range: UnboundedRange) -> [RegularExpressionMatch] {
        self.matches(in: string, options: options, range: NSRange(range, in: string)).map({ RegularExpressionMatch(unchecked: $0, in: string) })
    }
    
    func firstMatch<R: RangeExpression>(in string: String, options: NSRegularExpression.MatchingOptions, range: R) -> RegularExpressionMatch? where R.Bound == String.Index {
        self.firstMatch(in: string, options: options, range: NSRange(range, in: string)).map({ RegularExpressionMatch(unchecked: $0, in: string) })
    }
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions, range: UnboundedRange) -> RegularExpressionMatch? {
        self.firstMatch(in: string, options: options, range: NSRange(range, in: string)).map({ RegularExpressionMatch(unchecked: $0, in: string) })
    }
    
    func rangeOfFirstMatch<R: RangeExpression>(in string: String, options: NSRegularExpression.MatchingOptions, range: R) -> Range<String.Index>? where R.Bound == String.Index {
        Range(self.rangeOfFirstMatch(in: string, options: options, range: NSRange(range, in: string)), in: string)
    }
    func rangeOfFirstMatch(in string: String, options: NSRegularExpression.MatchingOptions, range: UnboundedRange) -> Range<String.Index>? {
        Range(self.rangeOfFirstMatch(in: string, options: options, range: NSRange(range, in: string)), in: string)
    }
    
    func stringByReplacingMatches<R: RangeExpression>(in string: String, options: NSRegularExpression.MatchingOptions, range: R, withTemplate template: String) -> String where R.Bound == String.Index {
        self.stringByReplacingMatches(in: string, options: options, range: NSRange(range, in: string), withTemplate: template)
    }
    func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions, range: UnboundedRange, withTemplate template: String) -> String {
        self.stringByReplacingMatches(in: string, options: options, range: NSRange(range, in: string), withTemplate: template)
    }
}
