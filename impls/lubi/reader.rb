# frozen_string_literal: true

class Tokenizer
  TOKENS = {
    IGNORE: /^(?:[\s,]+|;.*?(?:\n|$))/,
    STRING: /^"(?:\\.|[^\\"])*?"/,
    FLOAT: /^[0-9]+\.[0-9]+/,
    INTEGER: /^[0-9]+/,
    SYMBOL: %r{^(?:[+-/*^a-zA-Z0-9_<>]+|~@|[\[\]{}()'`~^])},
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
    tokens = tokenizer.(str)
    return nil unless tokens.any?

    read_form tokens
  end

  private

  def read_form(tokens)
    if tokens.peek.is_a?(MAL::Symbol)
      # try for pair
      right_pair = Pair.for(tokens.peek)
      return read_list(tokens, right_pair) unless right_pair.nil?

      # try for reader macros
      return read_macro(tokens, 'quote') if tokens.peek == "'"
      return read_macro(tokens, 'quasiquote') if tokens.peek == '`'
      return read_macro(tokens, 'unquote') if tokens.peek == '~'
      return read_macro(tokens, 'splice-unquote') if tokens.peek == '~@'
    end

    read_atom(tokens)
  rescue StopIteration
    raise UnexpectedEOF
  end

  def read_list(tokens, right_pair)
    tokens.next # consume left pair
    result = MAL::EmptyList.new
    while (token = read_form(tokens)) != right_pair
      result = result << token
    end
    result
  end

  def read_macro(tokens, macro)
    tokens.next # consume first
    MAL::List.new(MAL::Symbol.new(macro)) << read_form(tokens)
  end

  def read_atom(tokens)
    tokens.next
  end
end

class Pair
  PAIRS = [
    %w[( )],
    %w[[ ]],
    %w[{ }]
  ].freeze

  def self.for(string)
    PAIRS.each do |pair|
      return pair[1] if string == pair[0]
    end
    nil
  end
end

class UnexpectedEOF < StandardError; end
class InvalidTokenError < StandardError; end
