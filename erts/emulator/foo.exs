defmodule Fib do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(a), do: fib(a - 1) + fib(a - 2)
end

:erts_debug.df(Fib, :fib, 1)
IO.puts File.read!("Elixir.Fib_fib_1.dis")

IO.inspect :timer.tc(Fib, :fib, [10])
IO.inspect :timer.tc(Fib, :fib, [37])
IO.inspect :timer.tc(Fib, :fib, [37])
IO.inspect :timer.tc(Fib, :fib, [37])