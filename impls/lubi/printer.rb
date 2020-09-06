# frozen_string_literal: true

def pr_str(node)
  case node
  when MAL::Symbol
    node.name
  when Symbol # keyword
    ":#{node}"
  when String
    "\"#{node}\""
  when Array
    "(#{node.map { |item| pr_str(item) }.join(' ')})"
  else
    node
  end
end
