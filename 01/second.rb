cals =
  $stdin.each_line.each_with_object([0]) do |line, acc|
    if line.strip == ""
      acc << 0
      next
    end

    acc << acc.pop + line.strip.to_i
  end

puts cals.sort.reverse.take(3).sum
