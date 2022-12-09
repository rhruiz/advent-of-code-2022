defmodule RopeThisWorks do
  if "-d" in System.argv do
    def render(%{h: {hx, hy}, t: tpos} = state) do
      t = tpos |> Enum.with_index() |> Enum.into(%{}, fn {pos, idx} -> {pos, idx + 1} end)
      for y <- 15..-5, x <- -11..14 do
        chr = case {x, y} do
          {^hx, ^hy} -> "H"
          {x, y} when is_map_key(t, {x, y}) -> t[{x, y}]
          _ -> "."
        end

        IO.write(:stdio, chr)
        if(x == 14, do: IO.write(:stdio, "\n"))
      end

      state |> IO.inspect()
    end
  else
    def render(state), do: state
  end

  def run(stream) do
    state = %{h: {0, 0}, t: List.duplicate({0, 0}, 9), thistory: MapSet.new([{0, 0}])}

    stream
    |> Stream.flat_map(&parse/1)
    |> Enum.reduce(render(state), &move/2)
    |> Map.get(:thistory)
    |> MapSet.size()
    |> IO.inspect()
  end

  defp parse(<<dir, " ", amount::binary>>) do
    List.duplicate(delta(dir), String.to_integer(amount))
  end

  defp delta(dir) do
    case dir do
      ?R -> {1, 0}
      ?L -> {-1, 0}
      ?U -> {0, 1}
      ?D -> {0, -1}
    end
  end

  defp tdelta({hx, hy}, {tx, ty}) when abs(hx - tx) <= 1 and abs(hy - ty) <= 1 do
    {0, 0}
  end

  defp tdelta({hx, y}, {tx, y}) when abs(hx - tx) <= 2 do
    {Integer.floor_div(hx - tx, 2), 0}
  end

  defp tdelta({x, hy}, {x, ty}) when abs(hy - ty) <= 2 do
    {0, Integer.floor_div(hy - ty, 2)}
  end

  defp tdelta({hx, hy}, {tx, ty}) do
    for dx <- -1..1, dy <- -1..1, dx != 0, dy != 0 do
      {dx, dy}
    end
    |> Enum.find(fn delta ->
      {tx, ty} = apply_delta({tx, ty}, delta)

      abs(hx - tx) <= 1 && abs(hy - ty) <= 1
    end)
  end

  defp apply_delta({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  defp move(delta, state) do
    h = apply_delta(state.h, delta)

    move(h, %{state | h: h}, state.t, []) |> render()
  end

  defp move(_target, state, [], acc) do
    %{state | t: Enum.reverse(acc), thistory: MapSet.put(state.thistory, hd(acc))}
  end

  defp move(target, state, [head | tail], acc) do
    tdelta = tdelta(target, head)
    target = apply_delta(head, tdelta)

    move(target, state, tail, [target | acc])
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> RopeThisWorks.run()
