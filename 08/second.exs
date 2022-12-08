Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

grid =
  :stdio
  |> IO.stream(:line)
  |> Grid.new()

xmax = grid.xmax
ymax = grid.ymax

score = fn grid, x, y ->
  lxs = for xx <- x..0, {xx, y} != {x, y}, do: grid[{xx, y}]
  rxs = for xx <- x..xmax, {xx, y} != {x, y}, do: grid[{xx, y}]
  tys = for yy <- y..0, {x, yy} != {x, y}, do: grid[{x, yy}]
  bys = for yy <- y..ymax, {x, yy} != {x, y}, do: grid[{x, yy}]
  target = grid[{x, y}]

  Enum.reduce([{lxs, x}, {rxs, xmax - x}, {tys, y}, {bys, ymax - y}], 1, fn {coords, max}, score ->
    coords
    |> Enum.with_index(1)
    |> Enum.find({0, max}, fn {height, _index} ->
      height >= target
    end)
    |> then(fn {_, index} -> index * score end)
  end)
end

for x <- 1..(xmax-1), y <- 1..(ymax-1), reduce: 0 do
  candidate -> max(candidate, score.(grid, x, y))
end
|> IO.inspect()
