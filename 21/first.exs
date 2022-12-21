defmodule MonkeyMath do
  def operation("+", left, right), do: left + right
  def operation("-", left, right), do: left - right
  def operation("*", left, right), do: left * right
  def operation("/", left, right), do: left / right

  def parse(stream) do
    Enum.reduce(stream, %{}, fn
      <<monkey::binary-size(4), ": ", left::binary-size(4), " ", op::binary-size(1), " ", right::binary-size(4)>>, acc ->
        Map.put(acc, monkey, {op, left, right})

      <<monkey::binary-size(4), ": ", number::binary>>, acc ->
        Map.put(acc, monkey, String.to_integer(number))
    end)
  end

  def tree(monkeys) do
    tree(monkeys, "root")
  end

  def tree(monkeys, key) do
    monkey = monkeys[key]

    case monkey do
      {op, left, right} -> operation(op, tree(monkeys, left), tree(monkeys, right))
      number -> number
    end
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> MonkeyMath.parse()
|> MonkeyMath.tree()
|> trunc()
|> IO.inspect()
