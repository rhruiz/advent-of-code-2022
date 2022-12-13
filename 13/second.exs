defmodule Distressed do
  def compare([], []), do: :undefined

  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :right
      left > right -> :wrong
      true -> :undefined
    end
  end

  def compare(left, []) when is_list(left), do: :wrong
  def compare([], right) when is_list(right), do: :right

  def compare(left, right) when is_integer(left) and is_list(right) do
    compare([left], right)
  end

  def compare(left, right) when is_list(left) and is_integer(right) do
    compare(left, [right])
  end

  def compare([left | ltail], [right | rtail]) do
    case compare(left, right) do
      :undefined -> compare(ltail, rtail)
      other -> other
    end
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Stream.reject(&match?("", &1))
|> Stream.map(fn code ->
    code |> Code.eval_string() |> elem(0)
  end)
|> Stream.concat([[[2]]])
|> Stream.concat([[[6]]])
|> Enum.sort(fn left, right -> Distressed.compare(left, right) == :right end)
|> Stream.with_index(1)
|> Enum.into(%{})
|> Map.take([[[2]], [[6]]])
|> Map.values()
|> Enum.reduce(&Kernel.*/2)
|> IO.inspect()
