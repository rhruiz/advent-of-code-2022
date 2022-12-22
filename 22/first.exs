Code.compile_file(Path.expand("../../lib/grid.ex", __ENV__.file))

defmodule MonkeyMap do
  require IEx

  def parse(stream) do
    parser = fn
      " " -> nil
      "#" -> "#"
      "." -> "."
    end

    grid =
      stream
      |> Stream.take_while(fn line -> line != "\n" end)
      |> Stream.map(&String.trim_trailing(&1, "\n"))
      |> Stream.with_index()
      |> Enum.reduce(%Grid{}, fn {line, y}, grid ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reduce(grid, fn {value, x}, grid ->
          Grid.put(grid, {x, y}, parser.(value))
        end)
      end)

    instructions =
      stream
      |> Stream.drop_while(fn line -> line != "\n" end)
      |> Stream.drop(1)
      |> Enum.find(&Function.identity/1)
      |> String.trim_trailing()
      |> to_charlist()
      |> Enum.chunk_by(&(&1 in 'RL'))
      |> Enum.map(fn
        chr when chr in ['R', 'L'] -> to_string(chr)
        int -> int |> to_string() |> String.to_integer()
      end)

    {instructions, grid}
  end

  def next(grid, {x, y}, {dx, dy}) do
    xs = cond do
      dx == 0 -> x..x
      x + dx > x  -> grid.xmin..x
      true -> grid.xmax..x
    end

    ys = cond do
      dy == 0 -> y..y
      y + dy > y  -> grid.ymin..y
      true -> grid.ymax..y
    end

    xs
    |> Stream.flat_map(fn x ->
      [x]
      |> Stream.cycle()
      |> Stream.zip(ys)
    end)
    |> Enum.find(fn pos -> grid[pos] != nil end)
  end

  def leftmost(grid, y) do
    grid.xmin..grid.xmax
    |> Enum.find(fn x -> grid[{x, y}] end)
    |> then(fn
      nil -> nil
      x -> {x, y}
    end)
  end

  @headings [
    {1, 0},
    {0, 1},
    {-1, 0},
    {0, -1}
  ]

  @delta %{"R" => 1, "L" => -1}

  def headings, do: @headings

  def turn(heading, dir) do
    index = Enum.find_index(@headings, &(&1 == heading))
    index = Integer.mod(index + @delta[dir], 4)

    Enum.at(@headings, index)
  end

  def run({instructions, grid}) do
    start = next(grid, {grid.xmax, grid.ymin}, {1, 0})
    heading = {1, 0}

    Enum.reduce(instructions, {grid, start, heading}, &move/2)
  end

  def move(rotate, {grid, pos, heading}) when rotate in ~w[R L] do
    {grid, pos, turn(heading, rotate)}
  end

  def move(steps, {grid, pos, heading}) do
    do_move(grid, pos, heading, steps)
  end

  def do_move(grid, pos, heading, 0) do
    {grid, pos, heading}
  end

  def do_move(grid, {x, y} = pos, {dx, dy} = heading, steps) do
    new = {x + dx, y + dy}

    case grid[new] do
      "#" ->
        {grid, pos, heading}

      "." ->
        do_move(grid, new, heading, steps - 1)

      nil ->
        next = next(grid, pos, heading)

        case grid[next] do
          "#" ->
            {grid, pos, heading}

          "." ->
            do_move(grid, next, heading, steps - 1)
        end
    end
  end
end

System.argv()
|> hd()
|> File.stream!()
|> MonkeyMap.parse()
|> MonkeyMap.run()
|> then(fn {_, {x, y}, heading} ->
  4*(x + 1) + 1000*(y + 1) + Enum.find_index(MonkeyMap.headings(), &(&1 == heading))
end)
|> IO.inspect()
