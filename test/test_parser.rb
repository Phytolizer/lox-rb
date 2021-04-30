require 'minitest/autorun'
require_relative '../lox'
require_relative '../scanner'
require_relative '../parser'
require_relative '../ast'

class TestParser < Minitest::Test
  private

  def setup_parse(input)
    lox = Lox.new
    scanner = Scanner.new(lox, input)
    tokens = scanner.scan_tokens
    assert !lox.had_error
    parser = Parser.new(lox, tokens)
    stmts = parser.parse
    assert !lox.had_error
    stmts
  end

  def setup_single_expression(input)
    stmts = setup_parse(input)
    assert_equal 1, stmts.length
    assert_instance_of Stmt::Expression, stmts[0]
    stmts[0].expression
  end

  public

  def test_example_expressions
    expr = setup_single_expression('1 + 2 * 3;')
    assert_equal '(+ 1 (* 2 3))', AstPrinter.new.print(expr)
    expr = setup_single_expression('-123 * (45.67);')
    assert_equal '(* (- 123) (group 45.67))', AstPrinter.new.print(expr)
  end
end
