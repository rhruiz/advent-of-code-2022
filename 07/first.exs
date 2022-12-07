defmodule Du do
  defmodule State do
    defstruct cwd: ["root"], map: %{["root"] => 0}
  end

  def new, do: %Du.State{}

  def usage(stream) do
    stream
    |> Enum.reduce(new(), &usage/2)
    |> then(fn state ->
      Enum.into(state.map, %{}, fn {dir, size} ->
        {dir |> Enum.reverse() |> Enum.join("/"), size}
      end)
    end)
  end

  defp usage("$ cd /", _state), do: new()
  defp usage("$ ls", state), do: state

  defp usage("$ cd ..", %{cwd: [_head | tail]} = state) do
    %{state | cwd: tail}
  end

  defp usage("$ cd " <> dir, %{cwd: cwd} = state) do
    cwd = [dir | cwd]

    %{state | cwd: cwd}
  end

  defp usage("dir " <> dir, %{cwd: cwd, map: map} = state) do
    map = Map.put_new(map, [dir | cwd], 0)

    %{state | map: map}
  end

  defp usage(line, %{cwd: cwd} = state) do
    [size, _entry] = String.split(line, " ")

    update_dir_usage(cwd, String.to_integer(size), state)
  end

  defp update_dir_usage([], _incr, state), do: state

  defp update_dir_usage([_head | tail] = path, incr, %{map: map} = state) do
    map = Map.update(map, path, incr, fn val -> val + incr end)

    update_dir_usage(tail, incr, %{state | map: map})
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Du.usage()
|> Enum.filter(fn {_path, size} -> size <= 100000 end)
|> Enum.reduce(0, fn {_path, size}, usage -> size + usage end)
|> IO.inspect()
