defmodule Du do
  defmodule State do
    defstruct cwd: [], map: %{}
  end

  def new, do: %Du.State{}

  def handle("$ cd /", _state) do
    new()
  end

  def handle("$ ls", state), do: state

  def handle("$ cd ..", %{cwd: cwd} = state) do
    {_, cwd} = List.pop_at(cwd, -1)
    %{state | cwd: cwd}
  end

  def handle("$ cd " <> dir, %{cwd: cwd} = state) do
    cwd = cwd ++ [dir]

    %{state | cwd: cwd}
  end

  def handle("dir " <> dir, %{cwd: cwd, map: map} = state) do
    map = update_in(map, cwd ++ [dir], fn val -> val || %{} end)

    %{state | map: map}
  end

  def handle(line, %{cwd: cwd, map: map} = state) do
    [size, entry] = String.split(line, " ")

    map = put_in(map, cwd ++ [entry], String.to_integer(size))

    %{state | map: map}
  end

  def usage(tree) do
    usage(Enum.into(tree.map, []), ["root"], %{})
  end

  defp usage([], _, state), do: state

  defp usage(entry, path, state) when is_map(entry) do
    usage(Enum.into(entry, []), path, state)
  end

  defp usage([{entry, sub_tree} | tail], path, state) when is_map(sub_tree) do
    state = usage(sub_tree, [entry | path], Map.put_new(state, Enum.join([entry | path], "/"), 0))

    usage(tail, path, state)
  end

  defp usage([{_entry, size} | tail], path, state) do
    state = update_dir_usage(path, size, state)

    usage(tail, path, state)
  end

  defp update_dir_usage([], _incr, state), do: state

  defp update_dir_usage([_head | tail] = path, incr, state) do
    state = Map.update(state, Enum.join(path, "/"), incr, fn val -> val + incr end)

    update_dir_usage(tail, incr, state)
  end
end


usage =
  :stdio
  |> IO.stream(:line)
  |> Stream.map(&String.trim/1)
  |> Enum.reduce(Du.new(), &Du.handle/2)
  |> Du.usage()

total_disk = 70000000
used = usage["root"]
available = total_disk - used
required = 30000000 - available

usage
|> Enum.filter(fn {_dir, size} -> size >= required end)
|> Enum.sort_by(fn {_dir, size} -> size end)
|> hd()
|> IO.inspect()
