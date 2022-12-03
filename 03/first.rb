require 'set'

def priority(chr)
  if (prio = chr.ord - 'a'.ord + 1) >= 0
    prio
  else
    chr.ord - 'A'.ord + 27
  end
end

$stdin.each_line.each_with_object([]) { |line, acc|
  line = line.chars
  middle = line.length/2

  first = Set.new(line.slice(0...middle))
  second = Set.new(line.slice(middle..))
  common = first.intersection(second).first

  acc << priority(common)
}.sum.then(&method(:puts))
