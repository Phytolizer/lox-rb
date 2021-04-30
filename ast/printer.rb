# frozen_string_literal: true

require_relative '../ast'
require_relative '../token'

## Prints an AST in Lisp style.

class AstPrinter
  include Expr::Visitor

  def print(expr)
    expr.accept(self)
  end

  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping_expr(expr)
    parenthesize('group', expr.expression)
  end

  def visit_literal_expr(expr)
    if expr.value.nil?
      'nil'
    else
      expr.value.to_s.sub(/\.0$/, '')
    end
  end

  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  private

  def parenthesize(name, *exprs)
    buf = +"(#{name}"

    exprs.each do |expr|
      buf << " #{expr.accept(self)}"
    end
    buf << ')'

    buf
  end
end
