defmodule Sandbox do
  def new(stream) do
    stream
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(fn line ->
      line
      |> String.split(" -> ")
      |> Stream.map(fn pair ->
        pair |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)
      |> Stream.transform(nil, fn
        elem, nil -> {[], elem}
        elem, previous -> {[[previous, elem]], elem}
      end)
    end)
    |> Stream.flat_map(fn
      [[x1, y], [x2, y]] -> Stream.map(x1..x2, fn x -> {x, y} end)
      [[x, y1], [x, y2]] -> Stream.map(y1..y2, fn y -> {x, y} end)
    end)
    |> Enum.reduce(Grid.new([]), fn pos, grid -> Grid.put(grid, pos, "#") end)
  end
end
