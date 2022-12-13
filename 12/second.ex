Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

defmodule GoClimbARock do
  @deltas [
    {0, 1},
    {1, 0},
    {-1, 0},
    {0, -1}
  ]

  @target ?z - ?a + 1
  @start ?S - ?a

  def run(stream) do
    parser = fn
      "E" -> @target
      <<chr>> -> chr - ?a
    end

    map = Grid.new(stream, parser)
    target = Enum.find(map, &match?({_pos, @target}, &1)) |> elem(0)
    start = Enum.find(map, &match?({_pos, @start}, &1)) |> elem(0)

    map
    |> Grid.put(target, ?z - ?a)
    |> Grid.put(start, 0)
    |> navigate(target)
  end

  def navigate(map, target) do
    distances = %{target => 0}
    navigate(map, [{0, target}], distances)
  end

  def navigate(map, [{_, current} | queue], distances) do
    cond do
      map[current] == 0 ->
        distances[current]

      true ->
        {queue, distances} =
          for neighbor <- neighbors(map, current),
              distance = distances[current] + 1,
              distance < distances[neighbor],
              reduce: {queue, distances} do
            {queue, distances} ->
              distances = Map.put(distances, neighbor, distance)
              queue = enqueue(queue, neighbor, distance)

              {queue, distances}
          end

        navigate(map, queue, distances)
    end
  end

  defp enqueue([{current, _} | _] = queue, value, weight) when weight <= current do
    [{weight, value} | queue]
  end

  defp enqueue([head | tail], value, weight) do
    [head | enqueue(tail, value, weight)]
  end

  defp enqueue([], value, weight) do
    [{weight, value}]
  end

  def neighbors(map, {x, y}) do
    h = map[{x, y}]

    @deltas
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.flat_map(fn position ->
      case map[position] do
        nil -> []
        n when h > n + 1 -> []
        _ -> [position]
      end
    end)
  end
end

:stdio
|> IO.stream(:line)
|> GoClimbARock.run()
|> IO.inspect()
