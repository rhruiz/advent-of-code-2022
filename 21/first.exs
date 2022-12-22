defmodule MonkeyMath do
  def op(op, left, right), do: apply(Kernel, String.to_atom(op), [left, right])

  def parse(stream) do
    Enum.reduce(stream, %{}, fn
      <<monkey::binary-size(4), ": ", left::binary-size(4), " ", op::binary-size(1), " ",
        right::binary-size(4)>>,
      acc ->
        Map.put(acc, monkey, {op, left, right})

      <<monkey::binary-size(4), ": ", number::binary>>, acc ->
        Map.put(acc, monkey, String.to_integer(number))
    end)
  end

  def tree(monkeys), do: tree(monkeys, "root")

  def tree(mon, key) do
    case mon[key] do
      {op, left, right} -> op(op, tree(mon, left), tree(mon, right))
      number -> number
    end
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> MonkeyMath.parse()
|> MonkeyMath.tree()
|> IO.inspect()
