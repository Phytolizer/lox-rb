require_relative 'ast'

class Parser
  def initialize(lox, tokens)
    @lox = lox
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []
    statements << declaration while !at_end
    statements
  end

  private

  class ParseError < StandardError
  end

  def declaration
    return var_declaration if match(:VAR)
    statement
  rescue ParseError
    synchronize
    nil
  end

  def var_declaration
    name = consume(:IDENTIFIER, 'Expect variable name.')

    initializer = nil
    initializer = expression if match(:EQUAL)

    consume(:SEMICOLON, "Expect ';' after variable declaration.")
    Stmt::Var.new(name, initializer)
  end

  def statement
    return print_statement if match(:PRINT)
    expression_statement
  end

  def print_statement
    value = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    Stmt::Print.new(value)
  end

  def expression_statement
    expr = expression
    consume(:SEMICOLON, "Expect ';' after expression.")
    Stmt::Expression.new(expr)
  end

  def expression
    equality
  end

  def equality
    expr = comparison

    while match(:BANG_EQUAL, :EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = term

    while match(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def term
    expr = factor

    while match(:PLUS, :MINUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def factor
    expr = unary

    while match(:SLASH, :STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(:BANG, :MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end

    primary
  end

  def primary
    return Expr::Literal.new(false) if match(:FALSE)
    return Expr::Literal.new(true) if match(:TRUE)
    return Expr::Literal.new(nil) if match(:NIL)

    return Expr::Literal.new(previous.literal) if match(:NUMBER, :STRING)
    return Expr::Variable.new(previous) if match(:IDENTIFIER)

    if match(:LEFT_PAREN)
      expr = expression
      consume(:RIGHT_PAREN, "Expect ')' after expression.")
      return Expr::Grouping.new(expr)
    end

    raise error(peek, 'Expect expression.')
  end

  def synchronize
    advance

    while !at_end
      return if previous.type == :SEMICOLON

      case peek.type
      when :CLASS, :FUN, :VAR, :FOR, :IF, :WHILE, :PRINT, :RETURN
        return
      end

      advance
    end
  end

  def consume(type, message)
    return advance if check(type)
    raise error(peek, message)
  end

  def error(token, message)
    @lox.error(token, message)
    ParseError.new
  end

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end
    false
  end

  def check(type)
    if at_end
      false
    else
      peek.type == type
    end
  end

  def advance
    @current += 1 if !at_end
    previous
  end

  def at_end
    peek.type == :EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end
end
