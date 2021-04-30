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
    refute lox.had_error
    parser = Parser.new(lox, tokens)
    stmts = parser.parse
    refute lox.had_error
    stmts
  end

  def setup_single_expression(input)
    stmts = setup_parse(input)
    assert_equal 1, stmts.length
    assert_instance_of Stmt::Expression, stmts[0]
    stmts[0].expression
  end

  def print_single_expression(input)
    expr = setup_single_expression(input)
    AstPrinter.new.print(expr)
  end

  public

  def test_example_expressions
    assert_equal '(+ 1 (* 2 3))', print_single_expression('1 + 2 * 3;')
    assert_equal '(* (- 123) (group 45.67))', print_single_expression('-123 * (45.67);')
  end
end
