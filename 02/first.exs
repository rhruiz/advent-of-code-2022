defmodule D02E1 do
  def score(<<other, " ", me>>) do
    other = other - ?A + 1
    me = me - ?X + 1

    score(me, other) + me
  end

  # 1 - rock
  # 2 - paper
  # 3 - scissors

  @won 6
  @draw 3
  @lost 0

  def score(a, a), do: @draw
  def score(a, b) when a - b in [-2, 1], do: @won
  def score(a, b) when a - b in [2, -1], do: @lost
end

IO.stream(:stdio, :line)
|> Stream.map(&String.trim/1)
|> Stream.map(&D02E1.score/1)
|> Enum.reduce(0, &+/2)
|> IO.puts
