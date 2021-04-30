require 'minitest/autorun'

require_relative '../ast'
require_relative '../ast/printer'
require_relative '../token'

class TestAstPrinter < Minitest::Test
  def test_print
    expression = Expr::Binary.new(
      Expr::Unary.new(
        Token.new(:MINUS, '-', nil, 1),
        Expr::Literal.new(123)
      ),
      Token.new(:STAR, '*', nil, 1),
      Expr::Grouping.new(
        Expr::Literal.new(45.67)
      )
    )

    assert_equal '(* (- 123) (group 45.67))', AstPrinter.new.print(expression)
  end
end
