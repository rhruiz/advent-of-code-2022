require 'set'

priority = ->(chr) {
  if (prio = chr.ord - 'a'.ord + 1) >= 0
    prio
  else
    chr.ord - 'A'.ord + 27
  end
}

$stdin.each_line.map { |line, acc|
  line
    .strip
    .chars
    .each_slice(line.length/2)
    .map { |cs| Set.new(cs) }
    .reduce(&:intersection)
    .first
    .then(&priority)
}.sum.then(&method(:puts))
