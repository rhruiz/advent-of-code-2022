defmodule Snafu do
  defp digit(chr) do
    fn
      ?2 -> 2
      ?1 -> 1
      ?0 -> 0
      ?- -> -1
      ?= -> -2
      _ -> raise "boom"
    end
    |> apply([chr])
  end

  defp to_int_digit(int) do
    fn
      2 -> ?2
      1 -> ?1
      0 -> ?0
      -1 -> ?-
      -2 -> ?=
      _ -> raise "boom"
    end
    |> apply([int])
  end

  def to_integer(chrs) do
    chrs
    |> to_charlist()
    |> Enum.reverse()
    |> Enum.reduce({0, 0}, fn chr, {sum, exp} ->
      {sum + digit(chr) * Integer.pow(5, exp), exp + 1}
    end)
    |> elem(0)
  end

  def from_integer(int) do
    int
    |> from_integer(0, [])
    |> Enum.map(&to_int_digit/1)
    |> to_string()
  end

  def from_integer(0, 0, acc), do: acc

  def from_integer(0, carry, acc), do: [carry | acc]

  def from_integer(int, carry, acc) do
    {carry, current} = snafu_digit(rem(int, 5) + carry)

    from_integer(div(int, 5), carry, [current | acc])
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
|> Stream.map(&String.trim/1)
|> Stream.map(&Snafu.to_integer/1)
|> Enum.reduce(&Kernel.+/2)
|> Snafu.from_integer()
|> IO.inspect()
