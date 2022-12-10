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

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim/1)
|> Stream.concat(["noop"])
|> Asm.run()
|> Stream.filter(fn {clock, _} ->
  clock == 20 || Integer.mod(clock + 20, 40) == 0
end)
|> Stream.map(fn {clock, x} -> clock * x end)
|> Enum.reduce(0, &Kernel.+/2)
|> IO.inspect()
