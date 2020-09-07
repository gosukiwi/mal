# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'readline'
require_relative 'types'
require_relative 'reader'
require_relative 'printer'

class REPL
  REPL_ENV = {
    '+' => ->(a, b) { a + b },
    '-' => ->(a, b) { a - b },
    '*' => ->(a, b) { a * b },
    '/' => ->(a, b) { a / b }
  }.freeze

  def call(input)
    _print(_eval(read(input), REPL_ENV))
  rescue UnexpectedEOF
    'Reader Error: Unexpected EOF.'
  rescue InvalidTokenError
    'Tokenizer Error: Unexpected EOF.'
  rescue InvalidSymbolError => e
    e
  end

  private

  def read(input)
    reader = Reader.new
    reader.read(input)
  end

  def _eval(ast, env)
    return ast if ast.is_a?(MAL::EmptyList)
    return eval_ast(ast, env) unless ast.is_a?(MAL::List)

    # apply
    result = eval_ast(ast, env)
    result[0].call(*result[1..-1])
  end

  def eval_ast(ast, env)
    case ast
    when MAL::Symbol then env.fetch(ast.name) { raise InvalidSymbolError, "Could not find symbol: #{ast.name}" }
    when MAL::List then ast.map { |node| _eval(node, env) } # TODO: Return List instead of Array?
    when Array then ast.map { |node| _eval(node, env) }
    when Hash then ast.map { |key, node| [key, _eval(node, env)] }.to_h
    else
      ast
    end
  end

  def _print(input)
    pr_str(input)
  end
end

class InvalidSymbolError < StandardError; end

rep = REPL.new
while buf = Readline.readline('user> ', true)
  puts rep.(buf)
end
