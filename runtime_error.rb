class LoxRuntimeError < StandardError
  def initialize(token, message)
    @token = token
    @message = message
  end

  def to_s
    @message
  end

  attr_reader :token
end
