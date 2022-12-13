defmodule MonkeyBusiness do
  def parse(stream) do
    state = %{monkeys: %{}, curr: nil}

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

        put_in(state.curr, new)

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
    |> then(fn %{monkeys: monkeys} ->
      Enum.into(monkeys, %{}, fn {id, monkey} ->
        {id,
         Map.update!(monkey, :op, fn op ->
           fn old ->
             old |> op.() |> Integer.floor_div(3)
           end
         end)}
      end)
    end)
  end

  def simulate_rounds(monkeys, n) do
    Enum.reduce(1..n, monkeys, fn _, monkeys -> simulate_round(monkeys) end)
  end

  def simulate_round(monkeys) do
    monkeys
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce(monkeys, fn id, monkeys ->
      monkey = monkeys[id]

      simulate_monkey(monkey, monkeys, :queue.out(monkey.items))
    end)
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
|> MonkeyBusiness.simulate_rounds(20)
|> Enum.sort_by(fn {_id, monkey} -> -monkey.inspected end)
|> Enum.take(2)
|> Enum.reduce(1, fn {_id, monkey}, mb -> mb * monkey.inspected end)
|> IO.inspect(charlists: :as_lists)
