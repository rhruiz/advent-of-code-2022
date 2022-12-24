defmodule GPS do
  def render(list) do
    if "-d" in System.argv() do
      list
      |> Enum.map(fn {v, _} -> v end)
      |> IO.inspect()
    end

    list
  end

  def parse(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Enum.into([])
  end

  def run(og) do
    length = length(og)

    mixed = Enum.reduce(og, og, &mix(&1, &2, length))

    zero_index = Enum.find_index(mixed, &match?({0, _}, &1))
                 |> IO.inspect(label: "zero at")

    grove_indexes =
      [1000, 2000, 3000]
      |> Enum.map(&Integer.mod(&1 + zero_index, length))

    mixed
    |> Stream.with_index()
    |> Enum.reduce(0, fn {{n, _og}, index}, sum ->
      if(index in grove_indexes, do: sum + n, else: sum)
    end)
  end

  def mix({0, _}, acc, _), do: acc |> render()

  def mix({elem, og_index}, acc, length) do
    {left, [{^elem, ^og_index} = head | right]} =
      Enum.split_while(acc, fn {_, idx} -> idx != og_index end)

    index = length(left)
    new_index = Integer.mod(index + elem, length)

    split_at =
      cond do
        index + elem < 0 -> new_index - index + Integer.floor_div(index + elem, length)
        index + elem > length -> new_index - index + Integer.floor_div(index + elem, length)
        true -> new_index - index
      end

    case new_index do
      0 ->
        (left ++ right) ++ [head]

      new_index when new_index == index ->
        acc

      new_index when new_index > index ->
        {a, b} = Enum.split(right, split_at)

        (left ++ a) ++ [head | b]

      _ ->
        {a, b} = Enum.split(left, split_at)

        (a ++ [head | b]) ++ right
    end
    |> render()
  end
end

:stdio
|> IO.stream(:line)
|> GPS.parse()
|> GPS.run()
|> IO.inspect() # 7153
