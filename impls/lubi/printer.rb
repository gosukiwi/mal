# frozen_string_literal: true

def pr_str(node)
  case node
  when MAL::Symbol
    node.name
  when Symbol # keyword
    ":#{node}"
  when String
    "\"#{node}\""
  when Hamster::List
    "(#{node.map { |item| pr_str(item) }.join(' ')})"
  when Array
    "[#{node.map { |item| pr_str(item) }.join(' ')}]"
  when Hash
    "{#{node.map { |key, value| "#{pr_str(key)} #{pr_str(value)}" }.join(' ')}}"
  when nil
    "nil"
  else
    node
  end
end
