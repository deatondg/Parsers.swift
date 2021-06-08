//public struct IntegerParserOptions {
//    public enum Radix {
//        case automaticStrict
//        case automaticRelaxed
//        case base(Int)
//                
//        public static let binary: Self = .base(2)
//        public static let octal: Self = .base(8)
//        public static let decimal: Self = .base(10)
//        public static let dozenal: Self = .base(12)
//        public static let hexidecimal: Self = .base(16)
//        public static let hex: Self = .hexidecimal
//        
//        public static let `default`: Self = .automatic()
//    }
//    public let allowPrefixPlus: Bool
//    public let allowPrefixMinus: Bool
//    public let allowUnderscores: Bool
//}
//struct IntegerParser<I: FixedWidthInteger> {
//    let options:
//}
//
//enum Sign {
//    case positive
//    case negative
//}
//struct SignParser: ParserFromBuilder {
//    typealias Output = Sign
//    typealias Failure = Never
//    
//    let allowPrefixPlus: Bool
//    let allowPrefixMinus: Bool
//    
//    var parser: Parser<Sign, Never> {
//        OneOf {
//            if allowPrefixPlus { Parsers.prefix("+").replaceOutputs(with: Sign.positive) }
//            if allowPrefixMinus { Parsers.prefix("-").replaceOutputs(with: Sign.negative) }
//            Parsers.just(Sign.positive)
//        }
//    }
//}
