Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

defmodule Blizzard do
  def d({x, y}, {dx, dy}), do: {x + dx, y + dy}

  def norm_time(grid, time) do
    lcm = Integer.floor_div(grid.xmax*grid.ymax, Integer.gcd(grid.xmax, grid.ymax))
    Integer.mod(time, lcm)
  end

  def blizzards(grid, blizzards, time, cache) do
    case cache[time] do
      nil ->
        blizzards = Enum.into(blizzards, MapSet.new(), &next(grid, &1))
        bpos = Enum.into(blizzards, MapSet.new(), &elem(&1, 0))
        {blizzards, bpos, Map.put(cache, time, {blizzards, bpos})}

      {blizzards, bpos} ->
        {blizzards, bpos, cache}
    end
  end

  def next(grid, {pos, delta}) do
    new = d(pos, delta)

    case {grid, new} do
      {%{xmin: xmin, xmax: xmax}, {xmax, y}} -> {{xmin + 1, y}, delta}
      {%{xmin: xmin, xmax: xmax}, {xmin, y}} -> {{xmax - 1, y}, delta}
      {%{ymin: ymin, ymax: ymax}, {x, ymax}} -> {{x, ymin + 1}, delta}
      {%{ymin: ymin, ymax: ymax}, {x, ymin}} -> {{x, ymax - 1}, delta}
      _ -> {new, delta}
    end
  end

  @deltas [{1, 0}, {0, 1}, {0, 0}, {-1, 0}, {0, -1}]

  def neighbors(grid, blizzards, pos) do
    @deltas
    |> Stream.map(&d(pos, &1))
    |> Stream.filter(fn {x, y} ->
      grid[{x, y}] != "#" &&
        x >= grid.xmin && x <= grid.xmax &&
        y >= grid.ymin && y <= grid.ymax
    end)
    |> Enum.filter(&(&1 not in blizzards))
  end

  def play({grid, blizzards, start, exit}) do
    initial = [{start, blizzards, 0}]
    {time, blizzards, cache} = navigate(grid, exit, :queue.from_list(initial), MapSet.new(), %{})
    {time_to_start, blizzards, cache} = navigate(grid, start, :queue.from_list([{exit, blizzards, time}]), MapSet.new(), cache)
    {there_and_back_again, _, _} = navigate(grid, exit, :queue.from_list([{start, blizzards, time_to_start}]), MapSet.new(), cache)

    there_and_back_again
  end

  def navigate(grid, exit, queue, visited, cache) do
    case :queue.out(queue) do
      {:empty, _} ->
        raise "boom"

      {{:value, {^exit, blizzards, time}}, _} ->
        {time, blizzards, cache}

      {{:value, {current, blizzards, time}}, queue} ->
        cond do
          {current, norm_time(grid, time)} in visited ->
            navigate(grid, exit, queue, visited, cache)

          true ->
            {blizzards, bpos, cache} = blizzards(grid, blizzards, time, cache)
            visited = MapSet.put(visited, {current, time})

            case neighbors(grid, bpos, current) do
              [] ->
                navigate(grid, exit, queue, visited, cache)

              neighbors ->
                queue =
                  Enum.reduce(neighbors, queue, fn neighbor, queue ->
                    :queue.in({neighbor, blizzards, time + 1}, queue)
                  end)

                navigate(grid, exit, queue, visited, cache)
            end
        end
    end
  end

  def parse(stream) do
    parser = fn
      "#" -> "#"
      "." -> nil
      ">" -> {1, 0}
      "<" -> {-1, 0}
      "v" -> {0, 1}
      "^" -> {0, -1}
    end

    grid = Grid.new(stream, parser)

    %{ymin: ymin, ymax: ymax} = grid

    {start, nil} = Enum.find(grid, &match?({{_x, ^ymin}, nil}, &1))
    {exit, nil} = Enum.find(grid, &match?({{_x, ^ymax}, nil}, &1))

    blizzards =
      Enum.flat_map(grid, fn
        {pos, {_dx, _dy} = delta} -> [{pos, delta}]
        _ -> []
      end)

    grid =
      Enum.reduce(grid, %Grid{}, fn
        {pos, "#"}, grid -> Grid.put(grid, pos, "#")
        _, grid -> grid
      end)

    {grid, blizzards, start, exit}
  end
end

:stdio
|> IO.stream(:line)
|> Blizzard.parse()
|> Blizzard.play()
|> IO.inspect()
