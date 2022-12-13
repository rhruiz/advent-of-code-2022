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
|> Stream.chunk_every(2)
|> Stream.map(fn parts ->
  Enum.map(parts, fn code ->
    code |> Code.eval_string() |> elem(0)
  end)
end)
|> Stream.with_index(1)
|> Stream.map(fn {[left, right], index} ->
  {index, Distressed.compare(left, right)}
end)
|> Stream.filter(&match?({_, :right}, &1))
|> Stream.map(&elem(&1, 0))
|> Enum.reduce(&Kernel.+/2)
|> IO.inspect()
