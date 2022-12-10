defmodule Asm do
  def run(code) do
    # {clock, X}
    state = {1, 1}

    Stream.transform(code, state, fn
      "noop", {clock, x} ->
        {[{clock, x}], {clock + 1, x}}
      "addx " <> val, {clock, x} ->
        val = String.to_integer(val)

        {[{clock, x}, {clock + 1, x}], {clock + 2, x + val}}
    end)
  end
end

defmodule Display do
  @colmax 39

  def run(stream) do
    # {drawing position, line buffer}
    state = {0, []}

    Stream.transform(stream, state, fn {_clock, x}, {position, buf} ->
      chr = if(position >= x - 1 && position <= x + 1, do: '#', else: '.')
      emit(position, [buf | [chr]])
    end)
  end

  defp emit(@colmax, buf), do: {[buf], {0, []}}
  defp emit(position, buf), do: {[], {position + 1, buf}}
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Stream.concat(["noop"])
|> Asm.run()
|> Display.run()
|> Stream.each(&IO.puts/1)
|> Stream.run()
