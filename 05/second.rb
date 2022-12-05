stacks = {}
orders = []

reading_stack = ->(line) {
  if line.include?("[")
    line.chars.each_slice(4).with_index do |chars, index|
      stacks[index] ||= []
      stacks[index].unshift(chars[1]) if chars[1] != " "
    end
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

$stdin.each_line do |line|
  if line == "\n"
    handler = reading_orders
    next
  end

  handler.(line)
end

orders.each do |count, from, to|
  buf = stacks[from].pop(count)
  stacks[to].push(*buf)
end

puts stacks.keys.sort.map { |k| stacks[k].last }.join("")
