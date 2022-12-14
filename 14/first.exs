Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))
Code.compile_file(Path.expand("../sandbox.ex", __ENV__.file))

defmodule SandTetris do
  @start {500, 0}

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
|> Sandbox.new()
|> SandTetris.simulate()
|> elem(1)
|> IO.inspect()
