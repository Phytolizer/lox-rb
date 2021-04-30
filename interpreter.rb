require_relative 'ast'
require_relative 'runtime_error'
require_relative 'environment'

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  def initialize(lox)
    @lox = lox
    @environment = Environment.new
  end

  def interpret(statements)
    statements.each do |stmt|
      execute(stmt)
    end
  rescue LoxRuntimeError => e
    @lox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when :BANG
      !truthy?(right)
    when :MINUS
      check_number_operand(expr.operator, right)
      -right
    else
      nil
    end
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when :GREATER
      check_number_operands(expr.operator, left, right)
      return left > right
    when :GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      return left >= right
    when :LESS
      check_number_operands(expr.operator, left, right)
      return left < right
    when :LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      return left <= right
    when :BANG_EQUAL
      return left != right
    when :EQUAL_EQUAL
      return left == right
    when :MINUS
      check_number_operands(expr.operator, left, right)
      return left - right
    when :SLASH
      check_number_operands(expr.operator, left, right)
      return left / right
    when :STAR
      check_number_operands(expr.operator, left, right)
      return left * right
    when :PLUS
      if left.is_a?(Float) && right.is_a?(Float)
        return left + right
      elsif left.is_a?(String) && right.is_a?(String)
        return left + right
      else
        raise LoxRuntimeError.new(expr.operator, 'Operands must be two numbers or two strings.')
      end
    end

    nil
  end

  def visit_variable_expr(expr)
    @environment.get(expr.name)
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
  end

  def visit_var_stmt(stmt)
    value = nil
    value = evaluate(stmt.initializer) unless stmt.initializer.nil?
    @environment.define(stmt.name.lexeme, value)
  end

  private

  def execute(stmt)
    stmt.accept(self)
  end

  def check_number_operand(operator, operand)
    return if operand.is_a?(Float)

    raise LoxRuntimeError.new(operator, 'Operand must be a number.')
  end

  def check_number_operands(operator, left, right)
    return if left.is_a?(Float) && right.is_a?(Float)

    raise LoxRuntimeError.new(operator, 'Operands must be numbers.')
  end

  def truthy?(obj)
    !obj.nil? && obj != false
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def stringify(obj)
    return 'nil' if obj.nil?

    if obj.is_a?(Float)
      text = obj.to_s
      text = text[0...text.length - 2] if text =~ /\.0$/
      return text
    end

    obj.to_s
  end
end
