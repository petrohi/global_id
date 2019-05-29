defmodule GlobalIdBench do
  use Benchfella

  setup_all do
    :ok = GlobalId.init()
    {:ok, nil}
  end

  bench "global_id" do
    _ = GlobalId.get_id()
    :ok
  end
end
