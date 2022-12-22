defmodule Operation do
  defstruct [:name, :op, :left, :right, :parent]
end

defmodule Value do
  defstruct [:name, :value, :parent]
end

defmodule MonkeyMath do
  def operation("+", left, right), do: left + right
  def operation("-", left, right), do: left - right
  def operation("*", left, right), do: left * right
  def operation("/", left, right), do: left / right

  def rev_op("+", _, result, other), do: result - other
  def rev_op("*", _, result, other), do: result / other

  def rev_op("/", :left, result, right), do: result * right
  def rev_op("/", :right, result, left), do: left / result

  def rev_op("-", :left, result, right), do: result + right
  def rev_op("-", :right, result, left), do: left - result

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

  def contains(node, key), do: find(node, key) != nil

  def find(node, name) do
    case node do
      %{name: ^name} -> node
      %Operation{} = op -> find(op.left, name) || find(op.right, name)
      _ -> nil
    end
  end

  def eval(node) do
    case node do
      %Value{} -> node.value
      %Operation{} -> operation(node.op, eval(node.left), eval(node.right))
    end
  end

  def tree(monkeys) do
    tree(monkeys, "root", nil, %{})
  end

  def tree(mon, key, parent, index) do
    index = Map.put(index, key, parent)

    case mon[key] do
      {op, left, right} ->
        {left, left_index} = tree(mon, left, key, index)
        {right, right_index} = tree(mon, right, key, index)

        {
          %Operation{
            parent: parent,
            name: key,
            op: op,
            left: left,
            right: right
          },
          Map.merge(left_index, right_index)
        }

      number ->
        {%Value{name: key, value: number, parent: parent}, index}
    end
  end

  def path_to(index, target), do: path_to(index, target, MapSet.new())

  def path_to(_index, "root", acc), do: acc

  def path_to(index, to, acc) do
    curr = index[to]
    path_to(index, curr, MapSet.put(acc, curr))
  end

  def dig(%{name: "humn"}, _, expected), do: expected

  def dig(node, path_to_humn, expected) do
    {humn_side, humn_tree, known} =
      if node.right.name in path_to_humn do
        {:right, node.right, node.left}
      else
        {:left, node.left, node.right}
      end

    humn_side_value = rev_op(node.op, humn_side, expected, eval(known))

    dig(humn_tree, path_to_humn, humn_side_value)
  end

  def guess({root, index}) do
    {side_with_humn, known} =
      if contains(root.left, "humn") do
        {root.left, root.right}
      else
        {root.right, root.left}
      end

    path = path_to(index, "humn")
    expected = eval(known)

    dig(side_with_humn, path, expected)
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> MonkeyMath.parse()
|> MonkeyMath.tree()
|> MonkeyMath.guess()
|> IO.inspect()
