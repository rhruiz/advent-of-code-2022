Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

defmodule ElvenMoves do
  @props [
    {[{0, -1}, {1, -1}, {-1, -1}], {0, -1}},
    {[{0, 1}, {1, 1}, {-1, 1}], {0, 1}},
    {[{-1, 0}, {-1, -1}, {-1, 1}], {-1, 0}},
    {[{1, 0}, {1, -1}, {1, 1}], {1, 0}}
  ]

  @deltas Enum.flat_map(@props, &elem(&1, 0))

  def parse(stream) do
    parser = fn
      "#" -> true
      _ -> nil
    end

    stream
    |> Grid.new(parser)
    |> Enum.reduce(%Grid{}, fn
      {_pos, nil}, grid -> grid
      {pos, val}, grid -> Grid.put(grid, pos, val)
    end)
  end

  def render({grid, _} = arg) do
    if "-d" in System.argv do
      Enum.each(grid.ymin..grid.ymax, fn y ->
        Enum.each(grid.xmin..grid.xmax, fn x ->
          IO.write(if(grid[{x, y}], do: "#", else: "."))
        end)
        IO.write("\n")
      end)

      IO.write("\n\n")
    end

    arg
  end

  def run(grid) do
    Enum.reduce(1..10, {grid, @props}, fn _, {grid, prop} ->
      round(grid, prop)
      |> render()
    end)
  end

  def can_move?(grid, elf) do
    Enum.any?(@deltas, fn delta -> grid[d(elf, delta)] != nil end)
  end

  def d({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def round(grid, props) do
    {hold, proposals} =
      for {elf, true} <- grid, reduce: {[], %{}} do
        {hold, proposals} ->
          if can_move?(grid, elf) do
            move =
              Enum.find(props, fn {checks, _} ->
                Enum.all?(checks, fn delta -> grid[d(elf, delta)] == nil end)
              end)

            if move != nil do
              {_, delta} = move
              {hold, Map.update(proposals, d(elf, delta), [elf], &[elf | &1])}
            else
              {[elf | hold], proposals}
            end
          else
            {[elf | hold], proposals}
          end
      end

    [head | tail] = props
    props = tail ++ [head]

    grid = Enum.reduce(hold, %Grid{}, &Grid.put(&2, &1, true))

    grid = Enum.reduce(proposals, grid, fn {to, elves}, grid ->
        case elves do
          [_elf] -> Grid.put(grid, to, true)
          elves -> Enum.reduce(elves, grid, &Grid.put(&2, &1, true))
        end
      end)

    {grid, props}
  end

  def area({grid, _}) do
    (abs(grid.xmax - grid.xmin) + 1) * (abs(grid.ymax - grid.ymin) + 1) - map_size(grid.map)
  end
end

:stdio
|> IO.stream(:line)
|> ElvenMoves.parse()
|> ElvenMoves.run()
|> ElvenMoves.area()
|> IO.inspect()
