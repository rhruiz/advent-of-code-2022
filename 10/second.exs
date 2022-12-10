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
  def run(stream) do
    Stream.transform(stream, 0, fn {_clock, x}, position ->
      eol = if(position == 39, do: ['\n'], else: [])

      chr = if position >= x - 1 && position <= x + 1 do
        '#'
      else
        '.'
      end

      {[chr | eol], Integer.mod(position + 1, 40)}
    end)
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Stream.concat(["noop"])
|> Asm.run()
|> Display.run()
|> Stream.each(&IO.write/1)
|> Stream.run()
