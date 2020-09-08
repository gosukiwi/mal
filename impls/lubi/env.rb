# frozen_string_literal: true

class Env
  attr_reader :outer, :data
  def initialize(outer = nil)
    @outer = outer
    @data = {}
  end

  def set(key, value)
    data[key] = value
  end

  def get(key)
    value = find(key)
    raise SymbolNotFoundError, "Symbol #{key} not found" if value.nil?

    value
  end

  def find(key)
    data[key] || outer&.find(key)
  end
end

class SymbolNotFoundError < StandardError; end
