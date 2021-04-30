# frozen_string_literal: true

require_relative 'runtime_error'

class Environment
  def initialize
    @values = {}
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    return @values[name] if @values.key?(name.lexeme)

    raise LoxRuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end
end
