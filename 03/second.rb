require 'set'

priority = ->(chr) {
  if (prio = chr.ord - 'a'.ord + 1) >= 0
    prio
  else
    chr.ord - 'A'.ord + 27
  end
}

$stdin.each_line.each_slice(3).map { |lines|
  lines
    .map { |l| Set.new(l.strip.chars) }
    .reduce(&:intersection)
    .first
    .then(&priority)
}.sum.then(&method(:puts))
