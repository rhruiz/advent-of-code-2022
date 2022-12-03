require 'set'

def priority(chr)
  if (prio = chr.ord - 'a'.ord + 1) >= 0
    prio
  else
    chr.ord - 'A'.ord + 27
  end
end

$stdin.each_line.each_slice(3).each_with_object([]) { |lines, acc|
  common = lines.map { |l| Set.new(l.strip.chars) }.reduce(&:intersection).first
  acc << priority(common)
}.sum.then(&method(:puts))
