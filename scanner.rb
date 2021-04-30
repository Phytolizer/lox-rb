# frozen_string_literal: true

require_relative 'token'

class String
  def digit?
    self >= '0' && self <= '9'
  end

  def letter?
    self >= 'a' && self <= 'z' || self >= 'A' && self <= 'Z' || self == '_'
  end
end

## The Lox scanner. Converts text to tokens.
class Scanner
  KEYWORDS = {
    'and' => :AND,
    'class' => :CLASS,
    'else' => :ELSE,
    'false' => :FALSE,
    'for' => :FOR,
    'fun' => :FUN,
    'if' => :IF,
    'nil' => :NIL,
    'or' => :OR,
    'print' => :PRINT,
    'return' => :RETURN,
    'super' => :SUPER,
    'this' => :THIS,
    'true' => :TRUE,
    'var' => :VAR,
    'while' => :WHILE
  }.freeze

  def initialize(lox, source)
    @lox = lox
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end
      @start = @current
      scan_token
    end

    @tokens.push Token.new(:EOF, '', nil, @line)
  end

  private

  def at_end
    @current >= @source.length
  end

  def scan_token
    c = advance
    case c
    when '('
      add_token :LEFT_PAREN
    when ')'
      add_token :RIGHT_PAREN
    when '{'
      add_token :LEFT_BRACE
    when '}'
      add_token :RIGHT_BRACE
    when ','
      add_token :COMMA
    when '.'
      add_token :DOT
    when '-'
      add_token :MINUS
    when '+'
      add_token :PLUS
    when ';'
      add_token :SEMICOLON
    when '*'
      add_token :STAR
    when '!'
      add_token(match('=') ? :BANG_EQUAL : :BANG)
    when '='
      add_token(match('=') ? :EQUAL_EQUAL : :EQUAL)
    when '<'
      add_token(match('=') ? :LESS_EQUAL : :LESS)
    when '>'
      add_token(match('=') ? :GREATER_EQUAL : :GREATER)
    when '/'
      if match '/'
        advance while peek != "\n" && !at_end
      else
        add_token :SLASH
      end
    when ' ', "\r", "\t"
      # do nothing
    when "\n"
      @line += 1
    when '"'
      string
    else
      if c.digit?
        number
      elsif c.letter?
        identifier
      else
        @lox.error(@line, 'Unexpected character.')
      end
    end
  end

  def identifier
    advance while peek.digit? || peek.letter?

    type = KEYWORDS[@source[@start...@current]]
    type = :IDENTIFIER if type.nil?
    add_token type
  end

  def number
    advance while peek.digit?
    if peek == '.' && peek_next.digit?
      advance
      advance while peek.digit?
    end

    add_token(:NUMBER, @source[@start...@current].to_f)
  end

  def peek_next
    if @current + 1 >= @source.length
      "\0"
    else
      @source[@current + 1]
    end
  end

  def string
    while peek != '"' && !at_end
      @line += 1 if peek == "\n"
      advance
    end

    if at_end
      @lox.error(@line, 'Unterminated string.')
      return
    end

    advance
    value = @source[@start + 1...@current - 1]
    add_token(:STRING, value)
  end

  def advance
    out = @source[@current]
    @current += 1
    out
  end

  def add_token(type, literal = nil)
    text = @source[@start...@current]
    @tokens.push Token.new(type, text, literal, @line)
  end

  def match(expected)
    return false if at_end
    return false if @source[@current] != expected

    @current += 1
    true
  end

  def peek
    if at_end
      "\0"
    else
      @source[@current]
    end
  end
end
