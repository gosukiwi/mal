# frozen_string_literal: true

class Tokenizer
  TOKENS = {
    STRING: /^"(?:\\.|[^\\"])*?"/,
    IGNORE: /^[\s,]+|;.*?(?:\n|$)/,
    FLOAT: /^[0-9]+\.[0-9]+/,
    INTEGER: /^[0-9]+/,
    SYMBOL: %r{^(?:[+-/*^a-zA-Z0-9_]+|[\[\]{}()'`~^@])},
    KEYWORD: %r{^:[+-/*^a-zA-Z0-9_]+}
  }.freeze

  def call(input)
    Enumerator.new do |yielder|
      while input != ''
        matched, remaining = tokenize_one(input)
        yielder << matched unless matched.nil?
        input = remaining
      end
    end
  end

  private

  def tokenize_one(input)
    TOKENS.each do |name, regex|
      match = regex.match(input)
      next unless match

      matched = name == :IGNORE ? nil : parse_token(match[0], name)
      remaining = input[match[0].length..-1]
      return [matched, remaining]
    end

    raise InvalidTokenError, "Invalid token: #{input[0]}"
  end

  def parse_token(match, name)
    case name
    when :STRING then match[1..-2]
    when :FLOAT then match.to_f
    when :INTEGER then match.to_i
    when :SYMBOL then MAL::Symbol.new(match)
    when :KEYWORD then match[1..-1].to_sym
    else
      raise "Could not parse token: #{name}"
    end
  end
end

class Reader
  attr_accessor :tokenizer
  def initialize
    @tokenizer = Tokenizer.new
  end

  def read(str)
    read_form tokenizer.(str)
  end

  private

  def read_form(tokens)
    # return read_list(tokens) if tokens.peek.is_a?(MAL::Symbol) && tokens.peek == '('
    if tokens.peek.is_a?(MAL::Symbol)
      right_pair = Pair.for(tokens.peek)
      return read_list(tokens, right_pair) unless right_pair.nil?
    end

    read_atom(tokens)
  rescue StopIteration
    raise UnexpectedEOF
  end

  def read_list(tokens, right_pair)
    tokens.next # consume left pair
    result = []
    while (token = read_form(tokens)) != right_pair
      result << token
    end
    result
  end

  def read_atom(tokens)
    tokens.next
  end
end

class Pair
  PAIRS = [
    %w[(  )],
    %w[[  ]],
    %w[{  }]
  ]

  def self.for(string)
    PAIRS.each do |pair|
      return pair[1] if string == pair[0]
    end
    nil
  end
end

class UnexpectedEOF < StandardError; end
class InvalidTokenError < StandardError; end
