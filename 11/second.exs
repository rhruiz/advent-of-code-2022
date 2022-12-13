defmodule MonkeyBusiness do
  def parse(stream) do
    state = %{count: 0, monkeys: %{}, curr: nil}

    Enum.reduce(stream, state, fn
      <<"Monkey ", id, ":">>, state ->
        new = %{
          id: id - ?0,
          inspected: 0,
          items: nil,
          op: nil,
          div: 0,
          throw: %{true: 0, false: 0}
        }

        state
        |> Map.put(:curr, new)
        |> Map.update!(:count, &(&1 + 1))

      "  Starting items: " <> items, state ->
        items = items |> String.split(", ") |> Enum.map(&String.to_integer/1)

        put_in(state.curr.items, :queue.from_list(items))

      "  Operation: new = " <> op, state ->
        {op, _} = Code.eval_string("fn old -> " <> op <> " end")

        put_in(state.curr.op, op)

      "  Test: divisible by " <> div, state ->
        put_in(state.curr.div, String.to_integer(div))

      "    If true: throw to monkey " <> monkey, state ->
        put_in(state.curr.throw.true, String.to_integer(monkey))

      "    If false: throw to monkey " <> monkey, state ->
        put_in(state.curr.throw.false, String.to_integer(monkey))

      "", %{monkeys: monkeys, curr: curr} = state ->
        %{state | monkeys: Map.put(monkeys, curr.id, curr)}
    end)
    |> then(fn %{monkeys: monkeys, curr: curr} = state ->
      %{state | monkeys: Map.put(monkeys, curr.id, curr)}
    end)
    |> then(fn %{monkeys: monkeys} = state ->
      common = Enum.reduce(monkeys, 1, fn {_, %{div: div}}, acc -> acc * div end)

      Map.put(
        state,
        :monkeys,
        Enum.into(monkeys, %{}, fn {id, monkey} ->
          {id,
           Map.update!(monkey, :op, fn op ->
             fn old ->
               old |> op.() |> Integer.mod(common)
             end
           end)}
        end)
      )
    end)
  end

  def simulate_rounds(state, n) do
    simulate_rounds(state.monkeys, state.count, n)
  end

  defp simulate_rounds(monkeys, _, 0), do: monkeys

  defp simulate_rounds(monkeys, count, round) do
    0..(count - 1)
    |> Enum.reduce(monkeys, fn id, monkeys ->
      monkey = monkeys[id]

      simulate_monkey(monkey, monkeys, :queue.out(monkey.items))
    end)
    |> simulate_rounds(count, round - 1)
  end

  defp simulate_monkey(monkey, monkeys, {:empty, queue}) do
    monkey = put_in(monkey.items, queue)
    Map.put(monkeys, monkey.id, monkey)
  end

  defp simulate_monkey(monkey, monkeys, {{:value, old}, queue}) do
    monkey =
      monkey
      |> Map.put(:items, queue)
      |> Map.update!(:inspected, &(&1 + 1))

    worry = monkey.op.(old)
    to = monkey.throw[Integer.mod(worry, monkey.div) == 0]

    monkeys =
      monkeys
      |> Map.put(monkey.id, monkey)
      |> update_in([to, :items], fn queue -> :queue.in(worry, queue) end)

    simulate_monkey(monkey, monkeys, :queue.out(queue))
  end
end

:stdio
|> IO.stream(:line)
|> Stream.map(&String.trim_trailing/1)
|> MonkeyBusiness.parse()
|> MonkeyBusiness.simulate_rounds(10_000)
|> Enum.sort_by(fn {_id, monkey} -> -monkey.inspected end)
|> then(fn [{_, a}, {_, b} | _tail] -> a.inspected * b.inspected end)
|> IO.inspect(charlists: :as_lists)
