defmodule Sample do
  def a() do
    :table = :ets.new(:table, [:named_table, :public])

    :ok = run(:bad_sample, :ensure_started_and_doit_badly, 0)
    :ok = run(:good_sample, :ensure_started_and_doit_goodly, 0)
    _ = :ets.delete(:table)
    :ok
  end

  defp run(name, fun, i) do
    case i do
      0 ->
        :ets.delete(:table, :key)
        :ets.insert_new(:table, {:key, 0})
        :erlang.send_after(1000, self(), :owari)
      _ ->
        :ok
    end
    receive do
      :owari ->
        # Print summary
        all = i
        [{:key, actual}] = :ets.lookup(:table, :key)
        IO.puts "#{name} finished. missing calls: #{all-actual} (#{actual}/#{all})"
        :ok
    after
      0 ->
        :ok = apply(ServerA, fun, [name])
        run(name, fun, i+1)
    end

  end
end
