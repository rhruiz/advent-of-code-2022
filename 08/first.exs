Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

grid =
  :stdio
  |> IO.stream(:line)
  |> Grid.new()

hidden = fn grid, x, y ->
  height = grid[{x, y}]
  xmax = grid.xmax
  ymax = grid.ymax

  lxs = for xx <- 0..x, {xx, y} != {x, y}, do: grid[{xx, y}]
  rxs = for xx <- x..xmax, {xx, y} != {x, y}, do: grid[{xx, y}]
  tys = for yy <- 0..y, {x, yy} != {x, y}, do: grid[{x, yy}]
  bys = for yy <- y..ymax, {x, yy} != {x, y}, do: grid[{x, yy}]

  Enum.any?(lxs, &(&1 >= height)) &&
    Enum.any?(rxs, &(&1 >= height)) &&
    Enum.any?(tys, &(&1 >= height)) &&
    Enum.any?(bys, &(&1 >= height))
end

trees_on_the_borders = (grid.xmax + 1) * (grid.ymax + 1) - (grid.xmax - 1) * (grid.ymax - 1)

for x <- 1..(grid.xmax - 1),
    y <- 1..(grid.ymax - 1),
    !hidden.(grid, x, y),
    reduce: trees_on_the_borders do
  count -> count + 1
end
|> IO.inspect()
