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

  public

  def test_single_tokens
    TOKEN_TYPES.each do |type|
      examples_for(type).each do |ex|
        lox = Lox.new
        s = Scanner.new(lox, ex)
        tokens = s.scan_tokens
        assert !lox.had_error, "lox had an error processing #{ex}"
        assert_equal type, tokens[0].type
        assert_equal ex, tokens[0].lexeme
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
          assert !lox.had_error, "lox had an error processing #{xleft}#{sep}#{xright}"
          assert_equal left, tokens[0].type
          assert_equal xleft, tokens[0].lexeme
          assert_equal right, tokens[1].type
          assert_equal xright, tokens[1].lexeme
        end
      end
    end
  end
end
