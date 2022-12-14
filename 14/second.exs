Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))
Code.compile_file(Path.expand("../sandbox.ex", __ENV__.file))

defmodule SandTetris do
  @start {500, 0}

  def simulate(grid) do
    move(grid, @start, 1, grid.ymax + 2)
  end

  defp get(_grid, {_x, ymax}, ymax), do: "#"
  defp get(grid, pos, _ymax), do: grid[pos]

  def move(grid, {x, y}, rounds, ymax) do
    case {get(grid, {x, y + 1}, ymax), get(grid, {x - 1, y + 1}, ymax),
          get(grid, {x + 1, y + 1}, ymax)} do
      {nil, _, _} ->
        move(grid, {x, y + 1}, rounds, ymax)

      {_, nil, _} ->
        move(grid, {x - 1, y + 1}, rounds, ymax)

      {_, _, nil} ->
        move(grid, {x + 1, y + 1}, rounds, ymax)

      _ when {x, y} == @start ->
        {grid, rounds}

      _ ->
        grid
        |> Grid.put({x, y}, "o")
        |> move(@start, rounds + 1, ymax)
    end
  end
end

:stdio
|> IO.stream(:line)
|> Sandbox.new()
|> SandTetris.simulate()
|> elem(1)
|> IO.inspect()
