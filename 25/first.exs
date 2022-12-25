defmodule Snafu do
  @to_integer %{
    ?2 => 2,
    ?1 => 1,
    ?0 => 0,
    ?- => -1,
    ?= => -2
  }

  @to_snafu %{
    2 => ?2,
    1 => ?1,
    0 => ?0,
    -1 => ?-,
    -2 => ?=
  }

  def to_integer(chrs) do
    to_integer(chrs, 0)
  end

  defp to_integer(<<>>, acc), do: acc

  defp to_integer(<<digit::size(8), tail::binary>>, acc) do
    to_integer(tail, @to_integer[digit] + acc * 5)
  end

  def from_integer(int) do
    int
    |> from_integer(0, [])
    |> Enum.map(&@to_snafu[&1])
  end

  defp from_integer(0, 0, acc), do: acc

  defp from_integer(0, carry, acc), do: [carry | acc]

  defp from_integer(int, carry, acc) do
    {carry, digit} = snafu_digit(rem(int, 5) + carry)
    next = div(int, 5)

    from_integer(next, carry, [digit | acc])
  end

  defp snafu_digit(int) do
    case rem(int, 5) do
      3 -> {1, -2}
      4 -> {1, -1}
      other -> {0, other}
    end
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Stream.map(&Snafu.to_integer/1)
|> Enum.reduce(&Kernel.+/2)
|> Snafu.from_integer()
|> IO.puts()
