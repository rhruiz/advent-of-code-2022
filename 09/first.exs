defmodule RopeThisWorks do
  if "-d" in System.argv do
    def render(%{h: {hx, hy}, t: {tx, ty}, thistory: th} = state) do
      IO.ANSI.clear() |> IO.puts()

      for y <- 12..-12, x <- -40..40 do
        chr = case {{x, y}, MapSet.member?(th, {x, y})} do
          {{^hx, ^hy}, _} -> "H"
          {{^tx, ^ty}, _} -> "T"
          {_, true} -> "#"
          _ -> "."
        end

        IO.write(:stdio, chr)
        if(x == 40, do: IO.write(:stdio, "\n"))
      end

      Process.sleep(50)

      state
    end
  else
    def render(state), do: state
  end

  def run(stream) do
    state = %{h: {0, 0}, t: {0, 0}, thistory: MapSet.new([{0, 0}])}

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
    t = apply_delta(state.t, tdelta(h, state.t))
    thistory = MapSet.put(state.thistory, t)

    render(%{state | h: h, t: t, thistory: thistory})
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> RopeThisWorks.run()
