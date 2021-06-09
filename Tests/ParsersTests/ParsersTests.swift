import XCTest
@testable import Parsers

final class ParsersTests: XCTestCase {
    func testDyck() {
        struct DyckParser: ParserFromBuilder {
            typealias Output = Int
            typealias Failure = Never

            var parser: Parser<Int, Never> {
                AllOf {
                    "("
                    self
                    ")"
                    self
                }
                .map({ (_, inner, _, outer) in inner + 1 + outer })
                .replaceFailures(withOutput: 0)
            }
        }

        let dyckParser = DyckParser()

        let example1 = "(()())()"
        let result1 = dyckParser.parse(from: example1)
        XCTAssert(result1.value == 4)
        XCTAssert(result1.endIndex == example1.endIndex)

        let example2 = "())()"
        let result2 = dyckParser.parse(from: example2)
        XCTAssert(result2.value == 1)
        XCTAssert(result2.endIndex == example2.index(example2.startIndex, offsetBy: 2))
    }
    
    func testSimpleExpr() throws {
        indirect enum Expr: ParsableFromBuilder {
            case sum(Term, Expr)
            case term(Term)
            
            typealias ParseFailure = NoMatchFailure
            static var parser: Parser<Expr, NoMatchFailure> {
                OneOf {
                    AllOf {
                        Term.self
                        "+"
                        Self.self
                    }
                    Term.self
                }
                .map({ o -> Self in
                    switch o {
                    case .c0(let (lhs, _, rhs)):
                        return .sum(lhs, rhs)
                    case .c1(let term):
                        return .term(term)
                    }
                })
                .mapFailures(\.v1)
            }
            
            var value: Int {
                switch self {
                case let .sum(term, expr):
                    return term.value + expr.value
                case let .term(term):
                    return term.value
                }
            }
        }
        
        indirect enum Term: ParsableFromBuilder {
            case product(Factor, Term)
            case factor(Factor)
            
            typealias ParseFailure = NoMatchFailure
            static var parser: Parser<Term, NoMatchFailure> {
                OneOf {
                    AllOf {
                        Factor.self
                        "*"
                        Self.self
                    }
                    Factor.self
                }
                .map({ o -> Self in
                    switch o {
                    case .c0(let (lhs, _, rhs)):
                        return .product(lhs, rhs)
                    case .c1(let factor):
                        return .factor(factor)
                    }
                    
                })
                .mapFailures(\.v1)
            }
            
            var value: Int {
                switch self {
                case let .product(factor, term):
                    return factor.value * term.value
                case let .factor(factor):
                    return factor.value
                }
            }
        }
        
        indirect enum Factor: ParsableFromBuilder {
            case expr(Expr)
            case value(Int)
            
            typealias ParseFailure = NoMatchFailure
            static var parser: Parser<Factor, NoMatchFailure> {
                OneOf {
                    AllOf {
                        "("
                        Expr.self
                        ")"
                    }
                    IntegerParser<Int>(options: .init(radix: .automatic, allowPrefixPlus: false, allowPrefixMinus: false, allowUnderscores: true))
                }
                .map({ o -> Self in
                    switch o {
                    case .c0(let (_, expr, _)):
                        return .expr(expr)
                    case .c1(let value):
                        return .value(value)
                    }
                })
                .mapFailures(\.v1)
            }
            
            var value: Int {
                switch self {
                case let .expr(expr):
                    return expr.value
                case let .value(value):
                    return value
                }
            }
        }
        
        let exprParser = Expr.parser.map(\.value)
        
        let exampleExpression = "(0x0+0b10)*100+0xFFFF_FFFF+0o10"
        let (result, index) = try exprParser.parse(from: exampleExpression)
        
        XCTAssertEqual(result, (0x0+0b10)*100+0xFFFF_FFFF+0o10)
        XCTAssertEqual(index, exampleExpression.endIndex)
    }
    
    func testExpr() throws {
        enum ExprFailure: Error {
            case expectedIntegerLiteral(String.Index)
            case expectedCloseParen(String.Index)
        }
        
        indirect enum Expr: ParsableFromBuilder {
            case sum(Term, Expr)
            case term(Term)
            
            typealias ParseFailure = ExprFailure
            static var parser: Parser<Expr, ExprFailure> {
                AllOf {
                    Term.self
                    "+".prefixParser().locatingFailures()
                    Expr.self
                }
                .map({ (term, _, expr) -> Expr in .sum(term, expr) })
                .recover({ f -> Result<(value: Expr, endIndex: String.Index), ExprFailure> in
                    switch f {
                    case .f0(let f):
                        return .failure(f)
                    case let .f1(f, term):
                        return .success((.term(term), f.index))
                    case .f2(let f, _, _):
                        return .failure(f)
                    }
                })
            }
            
            var value: Int {
                switch self {
                case let .sum(term, expr):
                    return term.value + expr.value
                case let .term(term):
                    return term.value
                }
            }
        }
        
        indirect enum Term: ParsableFromBuilder {
            case product(Factor, Term)
            case factor(Factor)
            
            typealias ParseFailure = ExprFailure
            static var parser: Parser<Term, ExprFailure> {
                AllOf {
                    Factor.self
                    "*".prefixParser().locatingFailures()
                    Term.self
                }
                .map({ (factor, _, term) -> Term in .product(factor, term) })
                .recover({ f -> Result<(value: Term, endIndex: String.Index), ExprFailure> in
                    switch f {
                    case .f0(let f):
                        return .failure(f)
                    case let .f1(f, factor):
                        return .success((.factor(factor), f.index))
                    case .f2(let f, _, _):
                        return .failure(f)
                    }
                })
            }
            
            var value: Int {
                switch self {
                case let .product(factor, term):
                    return factor.value * term.value
                case let .factor(factor):
                    return factor.value
                }
            }
        }
        
        indirect enum Factor: ParsableFromBuilder {
            case expr(Expr)
            case value(Int)
            
            typealias ParseFailure = ExprFailure
            static var parser: Parser<Factor, ExprFailure> {
                AllOf {
                    "("
                    Expr.self
                    ")".prefixParser().locatingFailures()
                }
                .map({ Factor.expr($0.1) })
                .catch({ f -> Result<Parser<Factor, ExprFailure>, ExprFailure> in
                    switch f {
                    case .f0:
                        return.success(
                            IntegerParser<Int>(options: .init(radix: .automatic, allowPrefixPlus: false, allowPrefixMinus: false, allowUnderscores: true))
                                .locatingFailures()
                                .map({ Factor.value($0) })
                                .mapFailures({ f -> ExprFailure in
                                    .expectedIntegerLiteral(f.index)
                                })
                        )
                    case .f1(let f, _):
                        return .failure(f)
                    case .f2(let f, _, _):
                        return .failure(.expectedCloseParen(f.index))
                    }
                })
                .mapFailures({ f -> ExprFailure in
                    switch f {
                    case .catchFailure(let f):
                        return f
                    case .parseFailure(let f):
                        return f
                    }
                })
            }
            
            var value: Int {
                switch self {
                case let .expr(expr):
                    return expr.value
                case let .value(value):
                    return value
                }
            }
        }
        
        let exprParser = Expr.parser.map(\.value)
        
        let exampleExpression = "(0x0+0b10)*100+0xFFFF_FFFF+0o10"
        let (result, index) = try exprParser.parse(from: exampleExpression)
        
        XCTAssertEqual(result, (0x0+0b10)*100+0xFFFF_FFFF+0o10)
        XCTAssertEqual(index, exampleExpression.endIndex)
    }
}
