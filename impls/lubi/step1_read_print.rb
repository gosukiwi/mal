# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'readline'
require_relative 'types'
require_relative 'reader'
require_relative 'printer'

def read(input)
  reader = Reader.new
  reader.(input)
end

def _eval(input)
  input
end

def _print(input)
  pr_str(input)
end

def rep(input)
  _print(_eval(read(input)))
rescue UnexpectedEOF
  'Reader Error: Unexpected EOF.'
rescue InvalidTokenError
  'Tokenizer Error: Unexpected EOF.'
end

while buf = Readline.readline('user> ', true)
  puts rep(buf)
end
