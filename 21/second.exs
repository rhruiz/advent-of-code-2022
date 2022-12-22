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
  def rev_op("-", :right, result, left), do: result - left

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

  def contains(node, key) do
    find(node, key) != nil
  end

  def find(node, name) do
    case node do
      %{name: ^name} ->
        node

      %Operation{left: left, right: right} ->
        find(left, name) || find(right, name)

      _ ->
        nil
    end
  end

  def expr(node) do
    case node do
      %Value{name: "humn"} -> "humn"
      %Value{} -> node.value
      %Operation{} -> "((#{expr(node.left)}) #{node.op} (#{expr(node.right)}))"
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

  def tree(monkeys, key, parent, index) do
    monkey = monkeys[key]
    index = Map.put(index, key, parent)

    case monkey do
      {op, left, right} ->
        {left, left_index} = tree(monkeys, left, key, index)
        {right, right_index} = tree(monkeys, right, key, index)

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

  def path_to(_index, "root", acc), do: Enum.reverse(acc)

  def path_to(index, to, acc) do
    curr = index[to]
    path_to(index, curr, [curr | acc])
  end

  def dig(%{name: "humn"}, _, expected), do: expected

  def dig(node, path_to_humn, expected) do
    {humn_side, humn_tree, known} =
      if node.right.name in path_to_humn do
        {:right, node.right, node.left}
      else
        {:left, node.left, node.right}
      end

    known = eval(known)
    humn_side_value = rev_op(node.op, humn_side, expected, known)

    IO.puts(
      "#{node.name} is #{expected}, #{humn_side} should be #{humn_side_value}, not #{humn_side} is #{known}"
    )

    dig(humn_tree, path_to_humn, humn_side_value)
  end

  def bsearch(fun, low, high) do
    if high >= low do
      mid = trunc((high + low)/2)
      op = fun.(mid)
      IO.puts "try #{mid} -> #{op}"

      case op do
        0 -> mid
        0.0 -> mid
        op when op < 0 -> bsearch(fun, low, mid - 1)
        _ -> bsearch(fun, mid + 1, high)
      end
    else
      raise "boom"
    end
  end

  def guess({root, index}) do
    {[guesswork], [expected]} = Enum.split_with([root.left, root.right], &contains(&1, "humn"))

    expected = eval(expected)

    {fun, _} = Code.eval_string("fn humn -> #{expr(guesswork)} - #{expected} end")


    {low, high} = Enum.min_max([0, trunc(fun.(0))])

    IO.inspect({low, high})

    bsearch(fun, low, high)
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> MonkeyMath.parse()
|> MonkeyMath.tree()
|> MonkeyMath.guess()
|> IO.inspect() # 3379022190351
