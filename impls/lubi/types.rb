# frozen_string_literal: true

require 'hamster/list'

module MAL
  class Symbol
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def to_s
      "<SYMBOL #{name}>"
    end

    def ==(other)
      return name == other if other.is_a?(String)
      return name == other.name if other.is_a?(::MAL::Symbol)
      false
    end
  end
end
