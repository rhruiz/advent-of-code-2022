defmodule Rock do
  @derive {Inspect, only: [:x, :y, :w, :h]}
  defstruct [:x, :y, :w, :h, map: %{}]

  def new(w, h, parts) do
    map =
      parts
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, line_no}, map ->
        line
        |> Enum.with_index()
        |> Enum.reduce(map, fn {chr, x}, map -> Map.put(map, {x, h - line_no - 1}, chr) end)
      end)

    %Rock{x: 0, y: 0, w: w, h: h, map: map}
  end

  def move_by(rock, dx, dy) do
    map =
      Enum.into(rock.map, %{}, fn {{x, y}, v} ->
        {{x + dx, y + dy}, v}
      end)

    %{rock | map: map, x: rock.x + dx, y: rock.y + dy}
  end

  def collision?(rock, grid) do
    Enum.any?(rock.map, fn
      {_, ?.} ->
        false

      {{x, y}, ?#} ->
        y < 0 || x < 0 || x > 6 || grid[{x, y}] == ?#
    end)
  end
end

jets =
  :stdio
  |> IO.read(:line)
  |> String.trim()
  |> to_charlist()
  |> Stream.cycle()
  |> Stream.map(fn
    ?> -> 1
    ?< -> -1
  end)

rocks =
  [
    [4, 1, ['####']],
    [3, 3, ['.#.', '###', '.#.']],
    [3, 3, ['..#', '..#', '###']],
    [1, 4, ['#', '#', '#', '#']],
    [2, 2, ['##', '##']]
  ]
  |> Enum.map(&apply(Rock, :new, &1))
  |> Enum.with_index()
  |> Enum.into(%{}, fn {v, k} -> {k, v} end)

idx = 0
height = 0
fallen = 0
top = Enum.into(0..6, %{}, fn i -> {i, -1} end)
grid = %{}

initial = {2, height + 3, idx, height, fallen, top, grid}

jets
|> Stream.transform(initial, fn jet, {x, y, idx, height, fallen, top, grid} ->
  rock = rocks[idx] |> Rock.move_by(x, y)

  move_x = Rock.move_by(rock, jet, 0)
  rock = if(Rock.collision?(move_x, grid), do: rock, else: move_x)

  move_y = Rock.move_by(rock, 0, -1)

  if !Rock.collision?(move_y, grid) do
    rock = move_y
    {[], {rock.x, rock.y, idx, height, fallen, top, grid}}
  else
    {top, grid} =
      rock.map
      |> Enum.reduce({top, grid}, fn
        {{x, y}, ?#}, {top, grid} ->
          {Map.put(top, x, max(top[x], y)), Map.put(grid, {x, y}, ?#)}

        _, state ->
          state
      end)

    height = Enum.max_by(top, fn {_, h} -> h end) |> elem(1) |> Kernel.+(1)
    fallen = fallen + 1

    {[{rock, fallen, height}], {2, height + 3, Integer.mod(idx + 1, 5), height, fallen, top, grid}}
  end
end)
|> Stream.drop_while(fn {_, fallen, _} -> fallen < 2022 end)
|> Enum.take(1)
|> IO.inspect()
