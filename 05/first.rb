stacks = {}
orders = []

reading_stack = ->(line) {
  if line.include?("[")
    line.chars.each_slice(4).with_index { |chars, index|
      stacks[index] ||= []
      stacks[index].unshift(chars[1]) if chars[1] != " "
    }
  end
}

reading_orders = ->(line) {
  parts = line.strip.split(" ")
  count = parts[1].to_i
  from = parts[3].to_i - 1
  to = parts[5].to_i - 1

  orders << [count, from, to]
}

handler = reading_stack

$stdin.each_line { |line|
  if line == "\n"
    handler = reading_orders
    next
  end

  handler.(line)
}

orders.each { |count, from, to|
  (0...count).each { |_i|
    elem = stacks[from].pop
    stacks[to].push(elem)
  }
}

puts stacks.keys.sort.map  { |k| stacks[k].last }.join("")
