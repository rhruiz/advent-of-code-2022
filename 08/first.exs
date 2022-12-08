Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

grid =
  :stdio
  |> IO.stream(:line)
  |> Grid.new()

hidden = fn grid, x, y ->
  height = grid[{x, y}]
  xmax = grid.xmax
  ymax = grid.ymax

  lxs = 0..x |> Stream.filter(fn xx -> {xx, y} != {x, y} end) |> Stream.map(&(grid[{&1, y}]))
  rxs = x..xmax |> Stream.filter(fn xx -> {xx, y} != {x, y} end) |> Stream.map(&(grid[{&1, y}]))
  tys = 0..y |> Stream.filter(fn yy -> {x, yy} != {x, y} end) |> Stream.map(&(grid[{x, &1}]))
  bys = y..ymax |> Stream.filter(fn yy -> {x, yy} != {x, y} end) |> Stream.map(&(grid[{x, &1}]))

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
