require_relative '../scanner'
require_relative '../token'
require_relative '../lox'

require 'minitest/autorun'

class TestScanner < Minitest::Test
  private

  SEPS = [' ', "\r", "\t"]

  def keyword_or_ident?(type)
    [
      :AND, :CLASS, :ELSE, :FALSE, :FOR, :FUN, :IF, :NIL,
      :OR, :PRINT, :RETURN, :SUPER, :THIS, :TRUE, :VAR, :WHILE,
      :IDENTIFIER
    ].include?(type)
  end

  def separators_for(left, right)
    if keyword_or_ident?(left) && keyword_or_ident?(right) || 
        [:BANG, :EQUAL, :LESS, :GREATER].include?(left) && [:EQUAL, :EQUAL_EQUAL].include?(right) ||
        left == :SLASH && right == :SLASH ||
        keyword_or_ident?(left) && right == :NUMBER ||
        left == :NUMBER && right == :NUMBER
      SEPS
    else
      ['']
    end
  end

  def scan(input)
    lox = Lox.new
    s = Scanner.new(lox, input)
    s.scan_tokens
  end

  def check_error(input, message)
    assert_output(nil, "#{message}\n") do
      scan(input)
    end
  end

  def assert_token(token, type, lexeme, literal = nil)
    assert_equal type, token.type
    assert_equal lexeme, token.lexeme
    assert_equal literal, token.literal unless literal.nil?
  end

  public

  def test_single_tokens
    TOKEN_TYPES.each do |type|
      examples_for(type).each do |ex|
        lox = Lox.new
        s = Scanner.new(lox, ex)
        tokens = s.scan_tokens
        refute lox.had_error, "lox had an error processing #{ex}"
        assert_token tokens[0], type, ex
      end
    end
  end

  def test_combined_tokens
    TOKEN_TYPES.product(TOKEN_TYPES).each do |left, right|
      separators_for(left, right).each do |sep|
        examples_for(left).product(examples_for(right)).each do |xleft, xright|
          lox = Lox.new
          s = Scanner.new(lox, "#{xleft}#{sep}#{xright}")
          tokens = s.scan_tokens
          refute lox.had_error, "lox had an error processing #{xleft}#{sep}#{xright}"
          assert_token tokens[0], left, xleft
          assert_token tokens[1], right, xright
        end
      end
    end
  end

  def test_invalid_numbers
    tokens = scan('3.')
    assert_equal 3, tokens.length
    assert_token tokens[0], :NUMBER, '3', 3
    assert_token tokens[1], :DOT, '.'
    assert_token tokens[2], :EOF, ''

  end

  def test_errors
    check_error('@', '[line 1] Error: Unexpected character.')
    check_error('true@', '[line 1] Error: Unexpected character.')
    check_error("true\n@", '[line 2] Error: Unexpected character.')
    check_error('"test', '[line 1] Error: Unterminated string.')
  end
end
