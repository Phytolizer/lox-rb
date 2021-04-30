# frozen_string_literal: true

require_relative 'scanner'
require_relative 'parser'
require_relative 'ast/printer'
require_relative 'interpreter'

## The main program.
class Lox
  def initialize
    @had_error = false
    @had_runtime_error = false
    @interpreter = Interpreter.new(self)
  end

  def run(source)
    scanner = Scanner.new(self, source)
    tokens = scanner.scan_tokens
    parser = Parser.new(self, tokens)

    stmts = parser.parse
    return if @had_error

    @interpreter.interpret(expr)
  end

  def run_file(path)
    contents = File.open(path).read
    run(contents)

    exit 65 if @had_error
    exit 70 if @had_runtime_error
  end

  def run_prompt
    loop do
      print '> '
      line = gets
      break if line.nil?

      run(line)
      @had_error = false
    end
  end

  def error(loc, message)
    if loc.is_a?(Token)
      if loc.type == :EOF
        report(loc.line, ' at end', message)
      else
        report(loc.line, " at '#{loc.lexeme}'", message)
      end
    else
      report(loc, '', message)
    end
  end

  def runtime_error(e)
    warn "#{e}\n[line #{e.token.line}]"
    @had_runtime_error = true
  end

  def report(line, where, message)
    warn "[line #{line}] Error#{where}: #{message}"
    @had_error = true
  end

  def main
    @had_error = false
    case ARGV.length
    when 0
      run_prompt
    when 1
      run_file $ARGV[0]
    else
      warn 'Usage: lox [script]'
      exit 64
    end
  end

  attr_reader :had_error
  attr_reader :had_runtime_error
end
