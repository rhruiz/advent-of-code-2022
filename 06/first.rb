require 'set'

$stdin.read.strip.chars.each_cons(4).reduce(4) do |index, chars|
  break index if Set.new(chars).length == 4
  index + 1
end.then(&method(:puts))
