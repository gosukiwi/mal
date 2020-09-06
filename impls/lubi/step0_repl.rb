# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'readline'

def read(input)
  input
end

def evl(input)
  input
end

def prnt(input)
  input
end

def rep(input)
  prnt evl(read(input))
end

while buf = Readline.readline('user> ', true)
  puts rep(buf)
end
