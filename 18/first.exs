defmodule Cubes do
  @deltas (for dx <- -1..1,
               dy <- -1..1,
               dz <- -1..1,
               {dx, dy, dz} != {0, 0, 0},
               abs(dx) + abs(dy) + abs(dz) == 1 do
             {dx, dy, dz}
           end)

  def parse(stream) do
    stream
    |> Enum.reduce(MapSet.new(), fn line, cubes ->
      [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer/1)
      MapSet.put(cubes, {x, y, z})
    end)
  end

  def faces(cubes) do
    Enum.reduce(cubes, 0, fn cube, faces ->
      faces + 6 - neighbors(cubes, cube)
    end)
  end

  def neighbors(cubes, {x, y, z}) do
    for {dx, dy, dz} <- @deltas,
        {x + dx, y + dy, z + dz} in cubes,
        reduce: 0 do
      count ->
          IO.inspect({dx, dy, dz})
          count + 1
    end
    |> IO.inspect(label: inspect({x, y, z}))
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Cubes.parse()
|> Cubes.faces()
|> IO.inspect()
