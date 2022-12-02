defmodule D02E2 do
  def score(<<other, " ", outcome>>) do
    other = other - ?A + 1
    outcome = 3*(outcome - ?X)

    me = my_play(other, outcome)
    score(me, other) + me
  end

  @rock 1
  @paper 2
  @scissors 3

  @won 6
  @draw 3
  @lost 0

  def my_play(a, @draw), do: a

  def my_play(@rock, @won), do: @paper
  def my_play(@paper, @won), do: @scissors
  def my_play(@scissors, @won), do: @rock

  def my_play(@rock, @lost), do: @scissors
  def my_play(@paper, @lost), do: @rock
  def my_play(@scissors, @lost), do: @paper

  def score(a, a), do: @draw
  def score(@rock, @scissors), do: @won
  def score(@rock, @paper), do: @lost
  def score(@paper, @rock), do: @won
  def score(@paper, @scissors), do: @lost
  def score(@scissors, @rock), do: @lost
  def score(@scissors, @paper), do: @won
end

IO.stream(:stdio, :line)
|> Stream.map(&String.trim/1)
|> Stream.map(&D02E2.score/1)
|> Enum.reduce(0, &+/2)
|> IO.puts
