defmodule Beacons do
  @re ~r/Sensor at x=(?<sx>\-?\d+), y=(?<sy>\-?\d+): closest beacon is at x=(?<bx>\-?\d+), y=(?<by>\-?\d+)/

  def parse(stream) do
    stream
    |> Stream.flat_map(fn str ->
      @re
      |> Regex.scan(str, capture: :all_but_first)
      |> hd()
      |> Stream.map(&String.to_integer/1)
      |> Stream.chunk_every(2)
      |> Stream.map(&List.to_tuple/1)
      |> Stream.chunk_every(2)
      |> Stream.map(&List.to_tuple/1)
    end)
    |> Enum.into(%{})
  end

  def md({xa, ya}, {xb, yb}), do: abs(xb - xa) + abs(yb - ya)

  def blank_on(sensor_data, y) do
    bxs =
      sensor_data
      |> Enum.flat_map(fn
        {_, {x, ^y}} -> [x]
        _ -> []
      end)
      |> Enum.into(MapSet.new())

    Enum.reduce(sensor_data, MapSet.new(), fn {{sx, sy} = sensor, beacon}, acc ->
      radius = md(sensor, beacon)

      cond do
        sy == y ->
          (sx - radius)..(sx + radius)

        sy > y ->
          overlap = max(0, radius - sy + y)
          (sx - overlap)..(sx + overlap)

        sy < y ->
          overlap = max(0, sy + radius - y)
          (sx - overlap)..(sx + overlap)
      end
      |> Enum.into(acc)
    end)
    |> MapSet.difference(bxs)
    |> MapSet.size()
  end
end


:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Beacons.parse()
|> Beacons.blank_on(System.argv |> hd() |> String.to_integer())
|> IO.inspect()
