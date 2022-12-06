require 'set'

$stdin.read.strip.chars.each_cons(14).reduce(14) do |index, chars|
  break index if Set.new(chars).length == 14
  index + 1
end.then(&method(:puts))
