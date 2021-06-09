import Foundation

public struct IntegerParserOptions {
    public enum Radix: ExpressibleByIntegerLiteral {
        case automatic
        case base(Int)
        
        public init(integerLiteral value: Int) {
            self = .base(value)
        }
                
        public static let binary: Self = .base(2)
        public static let octal: Self = .base(8)
        public static let decimal: Self = .base(10)
        public static let dozenal: Self = .base(12)
        public static let hexidecimal: Self = .base(16)
    }
    public let radix: Radix
    public let allowPrefixPlus: Bool
    public let allowPrefixMinus: Bool
    public let allowUnderscores: Bool
}

struct IntegerParser<I: FixedWidthInteger>: ParserFromBuilder {
    typealias Output = I
    typealias Failure = NoMatchFailure
    
    let options: IntegerParserOptions
    
    let digitsExpression: NSRegularExpression
    init(options: IntegerParserOptions) {
        self.options = options
        if options.allowUnderscores {
            digitsExpression = try! NSRegularExpression(pattern: "[0-9a-zA-Z_]*", options: [])
        } else {
            digitsExpression = try! NSRegularExpression(pattern: "[0-9a-zA-Z]*", options: [])
        }
    }
    
    var parser: Parser<I, NoMatchFailure> {
        AllOf {
            SignParser(allowPrefixPlus: options.allowPrefixPlus, allowPrefixMinus: options.allowPrefixMinus)
            switch options.radix {
            case .automatic:
                RadixParser()
            case .base(let base):
                Parsers.just(base)
            }
            digitsExpression.prefixParser()
        }
        .assertNonfailing()
        .map({ (sign, radix, digits) -> Result<I, NoMatchFailure> in
            let string = sign.string + (options.allowUnderscores ? digits.match.filter({ $0 != "_" }) : digits.match)
            
            return I(string, radix: radix).map({ .success($0) }) ?? .failure(.noMatch)
        })
    }
}

struct RadixParser: ParserFromBuilder {
    typealias Output = Int
    typealias Failure = Never
    
    var parser: Parser<Int, Never> {
        OneOf {
            Parsers.prefix("0b").replaceOutputs(with: 2)
            Parsers.prefix("0o").replaceOutputs(with: 8)
            Parsers.prefix("0x").replaceOutputs(with: 16)
        }
        .map({ $0.ignoreCases() })
        .replaceFailures(withOutput: 10)
    }
}

enum Sign {
    case positive
    case negative
    
    var string: String {
        switch self {
        case .positive:
            return ""
        case .negative:
            return "-"
        }
    }
}
struct SignParser: ParserFromBuilder {
    typealias Output = Sign
    typealias Failure = Never
    
    let allowPrefixPlus: Bool
    let allowPrefixMinus: Bool
    
    var parser: Parser<Sign, Never> {
        OneOf {
            if allowPrefixPlus { Parsers.prefix("+").replaceOutputs(with: Sign.positive) }
            if allowPrefixMinus { Parsers.prefix("-").replaceOutputs(with: Sign.negative) }
        }
        .map({ $0.ignoreCases() })
        .replaceFailures(withOutput: .positive)
    }
}
