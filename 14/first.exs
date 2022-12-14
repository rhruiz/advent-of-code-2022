Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

defmodule SandTetris do
  @start {500, 0}

  def grid(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(fn line ->
      line
      |> String.split(" -> ")
      |> Stream.map(fn pair ->
        pair |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)
      |> Stream.transform(nil, fn
        elem, nil -> {[], elem}
        elem, previous -> {[[previous, elem]], elem}
      end)
    end)
    |> Stream.flat_map(fn
      [[x1, y], [x2, y]] -> Stream.map(x1..x2, fn x -> {x, y} end)
      [[x, y1], [x, y2]] -> Stream.map(y1..y2, fn y -> {x, y} end)
    end)
    |> Enum.reduce(Grid.new([]), fn pos, grid -> Grid.put(grid, pos, "#") end)
  end

  def simulate(grid) do
    move(grid, @start, 0)
  end

  def move(%{xmin: xmin, xmax: xmax, ymax: ymax} = grid, {x, y}, rounds)
      when x < xmin or x > xmax or y > ymax do
    {grid, rounds}
  end

  def move(grid, {x, y}, rounds) do
    case {grid[{x, y + 1}], grid[{x - 1, y + 1}], grid[{x + 1, y + 1}]} do
      {nil, _, _} ->
        move(grid, {x, y + 1}, rounds)

      {_chr, nil, _} ->
        move(grid, {x - 1, y + 1}, rounds)

      {_, _chr, nil} ->
        move(grid, {x + 1, y + 1}, rounds)

      _ ->
        grid
        |> Grid.put({x, y}, "o")
        |> move(@start, rounds + 1)
    end
  end
end

:stdio
|> IO.stream(:line)
|> SandTetris.grid()
|> SandTetris.simulate()
|> elem(1)
|> IO.inspect()
