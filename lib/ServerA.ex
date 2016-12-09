defmodule ServerA do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, [], name: id)
  end

  def ensure_started_and_doit_badly(id) do
    {:ok, _pid} = ensure_started(id)

    # !! _Pid might be down here !!

    GenServer.cast(id, :doit)
  end
  
  def ensure_started_and_doit_goodly(id) do
    fun = fn() ->
      try do
	{:ok, _pid} = ensure_started(id)

	# !! _Pid might be down here !!

	GenServer.call(id, :doit)
      catch
	class, reason ->
#	  :io.format "ERR ~p : ~p~n", [class, reason]
	  {:error, {:catched, {class, reason}}}
      end
    end
    call_with_retry(fun, &need_retry/1, 5)
  end
  
  def init([]) do
    {:ok, 0}
  end
  
  def handle_call(:doit, _from, state) do
    _ = doit()
    {:reply, :ok, state}
  end

  def handle_cast(:doit, state) do
    _ = doit()
    {:noreply, state}
  end

  def handle_info(:die, state) do
    {:stop, :shutdown, state}
  end

  defp doit() do
    ms = 1 # This process will die soon!
    _ = :erlang.send_after(ms, self(), :die)
    _ = :ets.update_counter(:table, :key, 1)
    :ok
  end

  defp ensure_started(id) do
    case ServerA.Sup.start_child(id) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      err -> err
    end
  end

  defp need_retry({:error, {:catched, {:exit, {:shutdown, _}}}}) do true end
  defp need_retry({:error, {:catched, {:exit, {:noproc, _}}}}) do true end
  defp need_retry(_) do false end

  defp call_with_retry(fun, needRetryFun, n) do
    ret = fun.()
    case needRetryFun.(ret) do
      false ->
	ret
      true ->
	case n do
	  0 ->
	    IO.puts "Giving up..."
	    ret
	  _ ->
	    call_with_retry(fun, needRetryFun, n-1)
	end
    end
  end

end
