defmodule Cubes do
  @deltas (for dx <- -1..1,
               dy <- -1..1,
               dz <- -1..1,
               {dx, dy, dz} != {0, 0, 0},
               abs(dx) + abs(dy) + abs(dz) == 1 do
             {dx, dy, dz}
           end)

  defstruct grid: MapSet.new(), xmin: nil, ymin: nil, zmin: nil, xmax: 0, ymax: 0, zmax: 0

  def parse(stream) do
    stream
    |> Enum.reduce(%__MODULE__{}, fn line, cubes ->
      [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer/1)

      %{
        cubes
        | grid: MapSet.put(cubes.grid, {x, y, z}),
          xmax: max(cubes.xmax, x),
          ymax: max(cubes.ymax, y),
          zmax: max(cubes.zmax, z),
          xmin: min(cubes.xmin, x),
          ymin: min(cubes.ymin, y),
          zmin: min(cubes.zmin, z)
      }
    end)
  end

  def faces(cubes) do
    faces =
      Enum.reduce(cubes.grid, 0, fn cube, faces ->
        neighbors = neighbors(cube)
        count = Enum.count(neighbors, &(&1 in cubes.grid))

        faces + 6 - count
      end)

    initial = {cubes.xmin, cubes.ymin, cubes.zmin}

    filled = fill(cubes, [initial], MapSet.new([initial]))

    for x <- cubes.xmax..cubes.xmin,
        y <- cubes.ymax..cubes.ymin,
        z <- cubes.zmax..cubes.zmin,
        {x, y, z} not in filled,
        {x, y, z} not in cubes.grid,
        reduce: faces do
      faces -> faces - Enum.count(neighbors({x, y, z}), fn cube -> cube in cubes.grid end)
    end
  end

  defp fill(_cubes, [], acc), do: acc

  defp fill(cubes, [current | queue], acc) do
    {queue, acc} =
      current
      |> neighbors()
      |> Enum.filter(fn {x, y, z} ->
        x >= cubes.xmin && y >= cubes.ymin && z >= cubes.zmin &&
          x <= cubes.xmax && y <= cubes.ymax && z <= cubes.zmax
      end)
      |> Enum.filter(fn cube -> cube not in acc && cube not in cubes.grid end)
      |> Enum.reduce({queue, acc}, fn cube, {queue, acc} ->
        {[cube | queue], MapSet.put(acc, cube)}
      end)

    fill(cubes, queue, acc)
  end

  defp neighbors({x, y, z}) do
    for {dx, dy, dz} <- @deltas, n = {x + dx, y + dy, z + dz}, do: n
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Cubes.parse()
|> Cubes.faces()
|> IO.inspect()
