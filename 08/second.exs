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

score = fn grid, x, y, xmax, ymax ->
  lxs = for xx <- x..0, {xx, y} != {x, y}, do: grid[{xx, y}]
  rxs = for xx <- x..xmax, {xx, y} != {x, y}, do: grid[{xx, y}]
  tys = for yy <- y..0, {x, yy} != {x, y}, do: grid[{x, yy}]
  bys = for yy <- y..ymax, {x, yy} != {x, y}, do: grid[{x, yy}]
  target = grid[{x, y}]

  Enum.reduce([{lxs, x}, {rxs, xmax - x}, {tys, y}, {bys, ymax - y}], 1, fn {coords, max}, score ->
    coords
    |> Enum.with_index(1)
    |> Enum.find({target, max}, fn {height, _index} ->
      height >= target
    end)
    |> then(fn {_, index} -> index * score end)
  end)
end

for x <- 1..(xmax-1), y <- 1..(ymax-1) do
  score.(grid, x, y, xmax, ymax)
end
|> Enum.max()
|> IO.inspect()
