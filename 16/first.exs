defmodule UnderPressure do
  def parse(stream) do
    stream
    |> Stream.map(fn str ->
      str
      |> String.split("; ")
      |> Enum.flat_map(fn
        "tunnels lead to valves " <> destinations ->
          [{:neighbors, String.split(destinations, ", ")}]

        "tunnel leads to valve " <> destination ->
          [{:neighbors, [destination]}]

        "Valve " <> valve ->
          [valve, "has", "flow", "rate=" <> rate] = String.split(valve, " ")

          [{:id, valve}, {:flow, String.to_integer(rate)}]
      end)
      |> Enum.into(%{})
    end)
    |> Enum.into(%{}, &Map.pop(&1, :id))
  end

  def relieve(map) do
    {best, _cache} = relieve("AA", [], map, 30, %{})

    best
  end

  def relieve(_, _, _, time_left, cache) when time_left <= 0, do: {0, cache}

  def relieve(current, path, map, time_left, cache) do
    cond do
      cached = cache[{current, path, time_left}] ->
        {cached, cache}

      true ->
        {best, cache} =
          if map[current].flow > 0 && current not in path do
            for neighbor <- map[current].neighbors,
                reduce: {0, cache} do
              {best, cache} ->
                {sub, cache} = relieve(neighbor, [current | path], map, time_left - 2, cache)
                best = max(best, sub + map[current].flow * (time_left - 1))

                {best, cache}
            end
          else
            {0, cache}
          end

        {best, cache} =
          for neighbor <- map[current].neighbors,
              reduce: {best, cache} do
            {best, cache} ->
              {sub, cache} = relieve(neighbor, path, map, time_left - 1, cache)
              {max(best, sub), cache}
          end

        {best, Map.put(cache, {current, path, time_left}, best)}
    end
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> UnderPressure.parse()
|> UnderPressure.relieve()
|> IO.inspect()
