$stdin.each_line.count { |line|
  ((s1, e1), (s2, e2)) = line
    .strip
    .split(",")
    .map { |range| range.split("-").map(&:to_i) }

  (s2 >= s1 && e2 <= e1) ||
  (s1 >= s2 && e1 <= e2) ||
  (s1 <= s2 && e1 >= s2 && e1 <= e2) ||
  (s2 <= s1 && e2 >= s1 && e2 <= e1)

}.then(&method(:puts))


__END__
----------------------------------

 |s1        |e1
     |s2         |e2

----------------------------------

            |s1        |e1
      |s2         |e2
