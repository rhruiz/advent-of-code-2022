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

  def find_signal(sensor_data, max) do
    radii = Enum.map(sensor_data, fn {sensor, beacon} -> {sensor, md(sensor, beacon)} end)

    sensor_data
    |> Stream.flat_map(fn {{xi, yi} = sensor, beacon} ->
      radius = md(sensor, beacon)

      Stream.concat([
        Stream.map(0..(radius + 1), fn i -> {xi + i, yi - radius - 1 + i} end),
        Stream.map(0..(radius + 1), fn i -> {xi - i, yi - radius - 1 + i} end),
        Stream.map(0..(radius + 1), fn i -> {xi + i, yi + radius + 1 - i} end),
        Stream.map(0..(radius + 1), fn i -> {xi - i, yi + radius + 1 - i} end)
      ])
    end)
    |> Stream.filter(fn {x, y} -> x > 0 && y > 0 && x <= max && y <= max end)
    |> Stream.filter(fn beacon ->
      Enum.all?(radii, fn {sensor, radius} ->
        md(sensor, beacon) > radius
      end)
    end)
    |> Enum.find(&Function.identity/1)
    |> then(fn {x, y} -> x * 4000000 + y end)
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Beacons.parse()
|> Beacons.find_signal(System.argv |> hd() |> String.to_integer())
|> IO.inspect()
