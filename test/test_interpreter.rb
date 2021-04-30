require 'minitest/autorun'
require_relative '../scanner'
require_relative '../parser'
require_relative '../interpreter'
require_relative '../lox'

class TestInterpreter < Minitest::Test
  private

  def setup_parse(input)
    lox = Lox.new
    scanner = Scanner.new(lox, input)
    tokens = scanner.scan_tokens
    return nil if lox.had_error

    parser = Parser.new(lox, tokens)
    stmts = parser.parse
    return nil if lox.had_error

    stmts
  end

  def setup_parse_valid(input)
    lox = Lox.new
    scanner = Scanner.new(lox, input)
    tokens = scanner.scan_tokens
    refute lox.had_error, "lox had an error scanning #{input}"

    parser = Parser.new(lox, tokens)
    stmts = parser.parse
    refute lox.had_error, "lox had an error parsing #{input}"

    stmts
  end

  def full_interpret(input)
    lox = Lox.new
    interpreter = Interpreter.new(lox)
    stmts = setup_parse_valid(input)
    interpreter.interpret(stmts)
    !lox.had_runtime_error
  end

  public

  def test_print
    stmts = setup_parse_valid('print 1;')
    lox = Lox.new
    interpreter = Interpreter.new(lox)
    assert_output(/1/) do
      interpreter.interpret(stmts)
    end
    refute lox.had_runtime_error
  end

  def test_binary_ops
    assert_output(/2/) { assert full_interpret('print 1 + 1;') }
    assert_output(/4/) { assert full_interpret('print 2 * 2;') }
    assert_output(/0\.5/) { assert full_interpret('print 1 / 2;') }
    assert_output(/-1/) { assert full_interpret('print 1 - 2;') }
  end
end
