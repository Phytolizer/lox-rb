# frozen_string_literal: true

require 'attr_extras'

TOKEN_TYPES = [
  :LEFT_PAREN, :RIGHT_PAREN, :LEFT_BRACE, :RIGHT_BRACE,
  :COMMA, :DOT, :MINUS, :PLUS, :SEMICOLON, :SLASH, :STAR,

  :BANG, :BANG_EQUAL,
  :EQUAL, :EQUAL_EQUAL,
  :LESS, :LESS_EQUAL,
  :GREATER, :GREATER_EQUAL,

  :IDENTIFIER, :STRING, :NUMBER,

  :AND, :CLASS, :ELSE, :FALSE, :FOR, :FUN, :IF, :NIL, :OR,
  :PRINT, :RETURN, :SUPER, :THIS, :TRUE, :VAR, :WHILE,

  :EOF
].freeze

def examples_for(type)
  case type
  when :LEFT_PAREN
    ['(']
  when :RIGHT_PAREN
    [')']
  when :LEFT_BRACE
    ['{']
  when :RIGHT_BRACE
    ['}']
  when :COMMA
    [',']
  when :DOT
    ['.']
  when :MINUS
    ['-']
  when :PLUS
    ['+']
  when :SEMICOLON
    [';']
  when :SLASH
    ['/']
  when :STAR
    ['*']
  when :BANG
    ['!']
  when :BANG_EQUAL
    ['!=']
  when :EQUAL
    ['=']
  when :EQUAL_EQUAL
    ['==']
  when :LESS
    ['<']
  when :LESS_EQUAL
    ['<=']
  when :GREATER
    ['>']
  when :GREATER_EQUAL
    ['>=']
  when :IDENTIFIER
    [
      'a',
      'abcd',
      'aBcD',
      'AbCd',
      'ABCD',
      'abc123',
      'abc_123',
      '_abcd',
      'abcd_'
    ]
  when :STRING
    [
      '""',
      '"a"',
      '"test"',
      '"test set"',
      '"this is a longer test"',
      '"#ILL3G4L CH4R4CT3R$#"'
    ]
  when :NUMBER
    [
      '1',
      '123',
      '1.0',
      '0.1',
      '123.456'
    ]
  when :AND
    ['and']
  when :CLASS
    ['class']
  when :ELSE
    ['else']
  when :FALSE
    ['false']
  when :FOR
    ['for']
  when :FUN
    ['fun']
  when :IF
    ['if']
  when :NIL
    ['nil']
  when :OR
    ['or']
  when :PRINT
    ['print']
  when :RETURN
    ['return']
  when :SUPER
    ['super']
  when :THIS
    ['this']
  when :TRUE
    ['true']
  when :VAR
    ['var']
  when :WHILE
    ['while']
  when :EOF
    []
  end
end

## A single unit of the Lox language.
class Token
  attr_reader_initialize :type, :lexeme, :literal, :line

  def to_s
    buf = +"#{type} #{lexeme}"
    buf << " #{literal}" unless literal.nil?
    buf
  end
end
