defmodule Grid do
  defstruct xmax: 0, ymax: 0, map: %{}

  @behaviour Access

  def new(lines, parser \\ &String.to_integer/1) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce(%__MODULE__{}, fn {line, y}, grid ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {height, x}, grid ->
        put(grid, {x, y}, parser.(height))
      end)
    end)
  end

  def put(grid, {x, y}, value) do
    %{
      grid
      | map: Map.put(grid.map, {x, y}, value),
        xmax: max(x, grid.xmax),
        ymax: max(y, grid.ymax)
    }
  end

  def get(grid, {x, y}) do
    Map.get(grid.map, {x, y})
  end

  @impl Access
  def fetch(%{map: map}, key) do
    Map.fetch(map, key)
  end

  @impl Access
  def get_and_update(grid, {x, y}, function) do
    map = Map.get_and_update(grid.map, {x, y}, function)

    %{grid | map: map}
  end

  @impl Access
  def pop(grid, {x, y}) do
    map = Map.pop(grid.map, {x, y})

    %{grid | map: map}
  end
end

defimpl Enumerable, for: Grid do
  def count(grid), do: {:ok, map_size(grid.map)}

  def member?(grid, {key, value}) do
    {:ok, match?(%{^key => ^value}, grid.map)}
  end

  def member?(_grid, _other) do
    {:ok, false}
  end

  def slice(%{map: map}) do
    size = map_size(map)
    {:ok, size, &do_slice(:maps.to_list(map), &1, &2, size)}
  end

  defp do_slice(_list, _start, 0, _size), do: []
  defp do_slice(list, start, count, size) when start + count == size, do: list |> Enum.drop(start)
  defp do_slice(list, start, count, _size), do: list |> Enum.drop(start) |> Enum.take(count)

  def reduce(%{map: map}, acc, fun) do
    Enumerable.List.reduce(:maps.to_list(map), acc, fun)
  end
end
