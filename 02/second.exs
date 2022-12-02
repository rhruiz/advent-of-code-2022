defmodule D02E2 do
  def score(<<other, " ", outcome>>) do
    other = other - ?A + 1
    outcome = 3*(outcome - ?X)

    me = my_play(other, outcome)
    score(me, other) + me
  end

  @won 6
  @draw 3
  @lost 0

  def my_play(a, @draw), do: a
  def my_play(a, @won), do: Integer.mod(a, 3) + 1
  def my_play(a, @lost), do: Integer.mod(a - 2, 3) + 1

  def score(a, a), do: @draw
  def score(a, b) when a - b in [-2, 1], do: @won
  def score(a, b) when a - b in [2, -1], do: @lost
end

IO.stream(:stdio, :line)
|> Stream.map(&String.trim/1)
|> Stream.map(&D02E2.score/1)
|> Enum.reduce(0, &+/2)
|> IO.puts
