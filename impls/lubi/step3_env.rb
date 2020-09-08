# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'readline'
require_relative 'types'
require_relative 'reader'
require_relative 'printer'
require_relative 'env'

class REPL
  attr_reader :env, :reader
  def initialize
    @reader = Reader.new
    @env = Env.new
    @env.set '+', ->(a, b) { a + b }
    @env.set '-', ->(a, b) { a - b }
    @env.set '*', ->(a, b) { a * b }
    @env.set '/', ->(a, b) { a / b }
  end

  def loop
    while buf = Readline.readline('user> ', true)
      puts rep(buf)
    end
  end

  private

  def rep(input)
    stringify(evaluate(read(input), env))
  rescue UnexpectedEOF
    'Reader Error: Unexpected EOF.'
  rescue InvalidTokenError
    'Tokenizer Error: Unexpected EOF.'
  rescue SymbolNotFoundError => e
    e
  end

  def read(input)
    reader.(input)
  end

  def evaluate(ast, env)
    return eval_ast(ast, env) unless ast.is_a?(Hamster::List)
    return ast if ast.empty?

    apply(ast, env)
  end

  def apply(list, env)
    if list.head.is_a?(MAL::Symbol)
      # def!
      return env.set(list[1].name, evaluate(list[2], env)) if list.head.name == 'def!'

      # let*
      if list.head.name == 'let*'
        scope = Env.new(env)
        list[1].each_slice(2) do |cons|
          scope.set(cons[0].name, evaluate(cons[1], scope))
        end

        return evaluate(list[2], scope)
      end
    end

    # everything else
    result = eval_ast(list, env)
    result[0].call(*result[1..-1])
  end

  def eval_ast(ast, env)
    case ast
    when MAL::Symbol then env.get(ast.name)
    when Hamster::List then ast.map { |node| evaluate(node, env) } # TODO: Return List instead of Array?
    when Array then ast.map { |node| evaluate(node, env) }
    when Hash then ast.map { |key, node| [key, evaluate(node, env)] }.to_h
    else
      ast
    end
  end

  def stringify(input)
    pr_str(input)
  end
end

REPL.new.loop
