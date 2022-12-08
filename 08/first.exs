{grid, xmax, ymax} =
  :stdio
  |> IO.stream(:line)
  |> Stream.map(&String.trim/1)
  |> Stream.with_index()
  |> Enum.reduce({%{}, 0, 0}, fn {line, y}, state ->
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(state, fn {height, x}, {grid, xmax, ymax} ->
      {Map.put(grid, {x, y}, String.to_integer(height)), max(x, xmax), max(y, ymax)}
    end)
  end)

hidden = fn grid, x, y, xmax, ymax ->
  height = grid[{x, y}]

  lxs = for xx <- 0..x, {xx, y} != {x, y}, do: grid[{xx, y}]
  rxs = for xx <- x..xmax, {xx, y} != {x, y}, do: grid[{xx, y}]
  tys = for yy <- 0..y, {x, yy} != {x, y}, do: grid[{x, yy}]
  bys = for yy <- y..ymax, {x, yy} != {x, y}, do: grid[{x, yy}]

  Enum.any?(lxs, &(&1 >= height)) &&
    Enum.any?(rxs, &(&1 >= height)) &&
    Enum.any?(tys, &(&1 >= height)) &&
    Enum.any?(bys, &(&1 >= height))
end

for x <- 1..(xmax - 1),
    y <- 1..(ymax - 1),
    !hidden.(grid, x, y, xmax, ymax) do
  {x, y}
end
|> Enum.reduce((xmax + 1) * (ymax + 1) - (xmax - 1) * (ymax - 1), fn _item, count ->
  count + 1
end)
|> IO.inspect()
