Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

grid =
  :stdio
  |> IO.stream(:line)
  |> Grid.new()

xmax = grid.xmax
ymax = grid.ymax

score = fn grid, x, y ->
  lxs = x..0 |> Stream.filter(fn xx -> {xx, y} != {x, y} end) |> Stream.map(&(grid[{&1, y}]))
  rxs = x..xmax |> Stream.filter(fn xx -> {xx, y} != {x, y} end) |> Stream.map(&(grid[{&1, y}]))
  tys = y..0 |> Stream.filter(fn yy -> {x, yy} != {x, y} end) |> Stream.map(&(grid[{x, &1}]))
  bys = y..ymax |> Stream.filter(fn yy -> {x, yy} != {x, y} end) |> Stream.map(&(grid[{x, &1}]))
  target = grid[{x, y}]

  Enum.reduce([{lxs, x}, {rxs, xmax - x}, {tys, y}, {bys, ymax - y}], 1, fn {coords, max}, score ->
    coords
    |> Stream.with_index(1)
    |> Enum.find({0, max}, fn {height, _index} -> height >= target end)
    |> then(fn {_, index} -> index * score end)
  end)
end

for x <- 1..(xmax-1), y <- 1..(ymax-1), reduce: 0 do
  candidate -> max(candidate, score.(grid, x, y))
end
|> IO.inspect()
