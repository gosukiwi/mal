# frozen_string_literal: true

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

  # Immutable single-linked list
  class List
    include Enumerable

    attr_reader :head, :tail
    def initialize(head = nil, tail = nil)
      @head = head
      @tail = tail
    end

    def <<(value)
      List.new(value, self)
    end

    def each(&block)
      return to_enum(:each) unless block_given?

      tail&.each(&block)
      block.call(head)
    end

    def self.empty
      EmptyList.new
    end
  end

  # Empty immutable single-linked list. This class is private, use it through
  # `List.empty`.
  class EmptyList
    include Enumerable

    def <<(value)
      List.new(value)
    end

    def each(&block)
      to_enum(:each) unless block_given?
    end
  end
end
